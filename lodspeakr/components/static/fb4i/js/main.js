$(document).ready(function(){
    var endpoint = 'http://logd.tw.rpi.edu/logd/sparql';
    endpoint = 'http://healthdata.tw.rpi.edu/sparql';
    var hashParams = {};
    var facetsLoaded = 0;
    var conf = {
      fetchLimit : 25,
      fetchOffset : 0,
      firstQuery : true
    };
    var ajaxObj = undefined;

    function _updateFacetFromHash(id){
      if(hashParams['keyword-search'] !== undefined && hashParams['keyword-search'] != ""){
        $("#keyword-search").val(hashParams['keyword-search']);
      }
      if(hashParams[id] !== undefined){
        $.each(hashParams[id], function(i, item){
          $("#select-"+id+" option[value='"+item+"']").attr("selected", true);
        });
      }
    }
    
    function _msgError(msg){
      $("#error-details").html(msg);
      $("#error-msg").modal('show');
    }
    
    function _executeQuery(){      
      var facetPatterns = "";
      var hashString = "#";
      var namedGraphStart = "", namedGraphEnd = "";
      //Stop ajax already existing request
      if(ajaxObj !== undefined){
        ajaxObj.abort();
      }

      if($("#keyword-search").val() !== undefined && $("#keyword-search").val() != "" && $("#keyword-search").val().length >= 3){
        facetPatterns += 'FILTER(regex(?datasetTitle, "'+$("#keyword-search").val()+'", "i")) '
        hashString +="keyword-search="+$("#keyword-search").val()+"&";
      }
      $.each(facets, function(i, item){
          var rightDelimiter = '>', leftDelimiter = '<';
          if(item.facetLabelPredicates === undefined){
            rightDelimiter = '"';
            leftDelimiter = '"';
          }
          selectedValues = $("#select-"+item.id+" option:selected");
          if(conf.firstQuery == true && selectedValues.length == 0 && item.default !== undefined){
            selectedValues.push($("#select-"+item.id+" option[value='"+item.default+"']").attr("selected", true));
          }
          hashString += item.id+"=";
          if(selectedValues.length > 1){
            facetPatterns += '{';
          }
          selectedValues.each(function(index, value){
              var filter = "";
              var objVar = $(value).val();
              if (item.facetEntityCast !== undefined){
                objVar = '?var'+parseInt(Math.random()*100000);
                filter = "FILTER("+item.facetEntityCast+"("+objVar+") = \""+$(value).val()+"\"^^"+item.facetEntityCast+")";
                rightDelimiter = "";
                leftDelimiter = "";
              }
              facetPatterns += '?dataset ' + item.facetPredicates[0] + ' '+leftDelimiter + objVar+ rightDelimiter +' .               '+filter;
              hashString += $(value).val()+"|";
              if(selectedValues.length > 1){
                if(index < selectedValues.length -1){
                  facetPatterns += '}UNION{';
                }else{
                  facetPatterns += '}';
                }
              }
          });
          hashString += "&";
      });
      firstQuery = false;
      prefixes = " ";
      var query = prefixes+'PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
      PREFIX foaf: <http://xmlns.com/foaf/0.1/> \
      PREFIX dcterms: <http://purl.org/dc/terms/> \
      PREFIX dgtwc: <http://data-gov.tw.rpi.edu/2009/data-gov-twc.rdf#> \
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
      PREFIX conversion: <http://purl.org/twc/vocab/conversion/> \
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#> \
      PREFIX dcat: <http://www.w3.org/ns/dcat#> \
      SELECT DISTINCT ?dataset ?datasetTitle ?datasetDescription WHERE { \
        '+namedGraphStart+'\
        ?dataset a conversion:AbstractDataset; \
                 dcterms:title ?datasetTitle .\
        '+facetPatterns+' \
        OPTIONAL{ ?dataset dcterms:description ?datasetDescription} \
        OPTIONAL{ ?dataset dgtwc:catalog_homepage ?catalogHomepage} \
      '+namedGraphEnd+' \
    }ORDER BY ?datasetTitle \
    LIMIT '+(conf.fetchLimit+1) +' \
    OFFSET '+(conf.fetchLimit*conf.fetchOffset);
    $("#results").empty().html('<div class="progress progress-striped active" style="width:70%;margin-left:auto;margin-right:auto;margin-bottom:auto;margin-top:auto;"><div class="bar" style="width: 100%;"></div></div>');
    ajaxObj = $.ajax({
        url: endpoint,
        beforeSend: function(jqXHR, settings) {
          jqXHR.setRequestHeader("Accept", "application/sparql-results+json");
        },
        data: {
          query: query
        },
        dataType: 'json',
        success: function(data){renderResults(data, conf)}
      });
          window.location.hash = hashString;

}


function _updateGUI(e){
  var currentSelect = $(e.target).attr("id"), passedCurrentSelect = false;
//  if(currentSelect !== undefined){
    var newPatterns = new Array();  
    $(".facet").each(function(index){
                            var selectId = $(this).attr("id");
                            if(passedCurrentSelect){
                             var aux = _getFacetData(index, facets[index-1], newPatterns);
                            }
                            $("#"+selectId+" option:selected").each(function(i, j){
                              //Addd filter in case of cast available
                              var filter = "", objVar = $(j).html(), delimiter = '"';
                              if(facets[index-1].facetEntityCast !==undefined){
                                objVar = '?var'+parseInt(Math.random()*100000);
                                delimiter = " ";
                                filter = "FILTER("+facets[index-1].facetEntityCast+"("+objVar+") = \""+$(j).html()+"\"^^"+facets[index-1].facetEntityCast+")";
                              }

                              var newPattern = '?x '+facets[index-1].facetPredicates[0] +' '+delimiter+ objVar + delimiter+'. '+filter;
                              if(facets[index-1].facetLabelPredicates !== undefined){
                                newPattern =  '?x '+facets[index-1].facetPredicates[0] +' [ '+facets[index-1].facetLabelPredicates+' '+delimiter+ objVar + delimiter+' ]. '+filter;
                              }

                                 newPatterns.push(newPattern);
                            });
                            if(selectId == currentSelect){
                              passedCurrentSelect = true;
                            }
                       });
//  }
  fetchOffset = 0;
  _executeQuery();
}

    function _getFacetData(i, item, existingFacets){
      var predicateLabels = "",
          labelVariable = "",
          sparqlLimit = 10,
          namedGraphStart = "",
          namedGraphEnd = "",
          thingVariable = '?thing',
          thingSelected =  thingVariable,
          selectedFacets = "";
      if(item.facetEntityCast !== undefined){
        thingVariable = thingVariable+'_1';
        thingSelected = item.facetEntityCast+'('+thingVariable+') AS ?thing';
      }
      if(item.limit !== undefined){
        sparqlLimit = item.limit;
      }
      if(item.facetLabelPredicates !== undefined){
        predicateLabels = thingVariable+' '+item.facetLabelPredicates+' ?thingLabel .';
        labelVariable = '?thingLabel';
      }

      if(existingFacets !== undefined){
         $.each(existingFacets, function(i){ selectedFacets+= existingFacets[i]; });
//         return;
      }
      var query = 'PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
      PREFIX foaf: <http://xmlns.com/foaf/0.1/> \
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#> \
      PREFIX dcterms: <http://purl.org/dc/terms/> \
      PREFIX dgtwc: <http://data-gov.tw.rpi.edu/2009/data-gov-twc.rdf#> \
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \
      PREFIX conversion: <http://purl.org/twc/vocab/conversion/> \
      PREFIX dcat: <http://www.w3.org/ns/dcat#> \
      SELECT DISTINCT '+thingSelected+' '+labelVariable+' WHERE { \
        '+namedGraphStart+'\
        ?x a conversion:AbstractDataset ; '+item.facetPredicates[0]+' '+thingVariable+' . '+selectedFacets+'\
        '+predicateLabels+' \
      '+namedGraphEnd+' \
    }ORDER BY '+labelVariable+' '+thingVariable+' \
    LIMIT 10000';
    $.ajax({
        url: endpoint,
        beforeSend: function(jqXHR, settings) {
          jqXHR.setRequestHeader("Accept", "application/sparql-results+json");
        },
        data: {
          query: query
        },
        dataType: 'json',
        async: false,
        success: function(data){
          options = "";
          $.each(data.results.bindings, function(index, value){
              var label = value.thing.value;
              if(value.thingLabel !== undefined){
                label = value.thingLabel.value;
              }
              options += '<option value="'+value.thing.value+'" data-name="'+label+'">'+label+'</option>';
          });
          if(existingFacets == undefined){
            $("#"+item.id).append('<button class="btn btn-mini clear-button" data-target="select-'+item.id+'">clear</button><select multiple class="select-facet facet" size="10" id="select-'+item.id+'">'+options+'</select>');
          }
          var currentSelection = new Array();
          $("#select-"+item.id+" option:selected").each(function(i){console.log("asd", $(this).val());currentSelection.push($(this).val());});
          $("#select-"+item.id).html(options);
          $.each(currentSelection, function(i, previouslySelected){$("#select-"+item.id+" option[value='"+previouslySelected+"']").attr("selected", true)});
          if(existingFacets == undefined){
            $('#waiting-'+item.id).addClass('hide');
            //Select values in case they are indicated in hash
            _updateFacetFromHash(item.id);
            if(++facetsLoaded == facets.length){
              $(".select-facet option:first").trigger('change');
            }
          }
        }
    });
}

function _clearFacet(e){
  var selectFacet = $(e.target).attr("data-target");
  $("#"+selectFacet+" option:selected").removeAttr("selected");
  $("#"+selectFacet).trigger('change'); 
}

function init(){
  $.each(facets, function(i, item){
      $("#facets").append('<div class="table-bordered facetDiv well" id="'+item.id+'"><div style="float:left;display:inline"><h3>'+item.id.charAt(0).toUpperCase() + item.id.slice(1)+'</h3></div><div id="waiting-'+item.id+'"class="progress progress-striped active"><div class="bar" style="width: 100%;"></div></div></div>');
      _getFacetData(i, item);
  });  
  $(".limit-label").html(conf.fetchLimit);
  $("#keyword-search").typing({
    stop: function (event, $elem) {
      if($elem.val().length >= 3 || $elem.val() === ""){
        $elem.trigger('change');
      }
      event.preventDefault();
    },
    delay: 400
});
  $("body").on('change', ".facet", _updateGUI); 
  $("body").on('click', ".clear-button", _clearFacet);
  $("body").on('click', ".pager-button", function(e){
      if($(e.target).is('.disabled')){return;}
      if($(e.target).attr("id") == 'previous'){
        conf.fetchOffset--;
      }
      if(conf.fetchOffset < 1){$("#previous").addClass('disabled');}
      if($(e.target).attr("id") == 'next'){      
        conf.fetchOffset++;
      }
      if(conf.fetchOffset > 0){$("#previous").removeClass('disabled');}

      _executeQuery();
  });
      _executeQuery();

}

function _parseArgs(){
  var r = {};
  var s = window.location.hash.slice(1);
  $.each(s.split('&'), function(i, item){
      if(item.length > 0){
        pair = item.split('=');
        if(pair[1].length >0){
          var values = [];
          $.each(pair[1].split('|'), function(index, val){if(val.length>1){values.push(val);}});
          r[pair[0]]= values;
        }
      }
  });
  return r;
}

//Init


hashParams = _parseArgs();
init();

});

