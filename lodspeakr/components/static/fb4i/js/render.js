function renderResults(data, conf){
          $("#results").empty();
          options = "";
          if(data.results.bindings.length > 0){$("#next").removeClass('disabled');}
          $.each(data.results.bindings, function(index, val){
            if(index == conf.fetchLimit){$("#next").removeClass('disabled'); return false;}
            $("#results").append('<div class="well"> \
                                   <div style="display:block;width:100%;margin-bottom:20px"> \
                                    <h3> \
                                     <a href="'+val.dataset.value+'">'+((val.datasetTitle.value != undefined)?val.datasetTitle.value:val.dataset.value)+'</a> \
                                    </h3> \
                                    <p>'+val.datasetDescription.value+'</p> \
                                  </div>');
          });
          if(data.results.bindings.length < conf.fetchLimit){$("#next").addClass('disabled');}
        }
