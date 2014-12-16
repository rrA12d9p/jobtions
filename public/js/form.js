$(document).ready(function(){
  $(".submit").click(function() {
    
    var rgroups = [];
    $('input:radio').each(function(index, el){
            var i;
            for(i = 0; i < rgroups.length; i++)
                if(rgroups[i] == $(el).attr('name'))
                    return true; //skip radios in existing groups
            rgroups.push($(el).attr('name'));
        }
    );
    rgroups = rgroups.length;

    if($('input:radio:checked').length < rgroups)
      {
        event.preventDefault(); //don't submit
        alert('Please make sure you\'ve answered every question.');
      }
  });
});