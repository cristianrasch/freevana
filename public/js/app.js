function showError(err) {
  $('p.results').text('');
  $('p.error').text(err);
}

function fetchSources(url) {
  // {"720":{"2":["wupload"]},"360":{"2":["megaupload","wupload"]}}
  $.get('/cuevana', { url: url }, function(data) {
    if(data.error)
      showError(data.error);
    else {
      var sources = data.sources;
      var metadata = data.metadata;
      
      var ul = $('<ul></ul>');
      var lis = $.map(Object.keys(sources), function(key, i) {
        var li = $('<li>'+key+'p - '+'</li>');
        var obj = sources[key];
        var audio = Object.keys(obj)[0];
        
        var links = $.map(obj[audio], function(e, i){
          var a = document.createElement('a');
          a.setAttribute('href', '#');
          a.setAttribute('class', 'link');
          a.appendChild(document.createTextNode(e));
          $.data(a, 'def', key);
          $.data(a, 'audio', audio);
          $.data(a, 'host', e);
          $.data(a, 'id', metadata.id);
          $.data(a, 'type', metadata.type);
          return a;
        });
        
        $.each(links, function(i, e){
          li.append(e);
          if(i < links.length -1)
            li.append(', ');
        });
        
        return li;
      });
      
      $.each(lis, function(i, e){
        ul.append(e);
      });
      $('p.results').html(ul);
    }
    
    $('input.btn').removeAttr('disabled');
    $('#wheel').css('visibility', 'hidden');
  });
}

function fetchSource(url) {
  $.get('/peliplay', { url: url }, function(data) {
    window.location = data;
  });
}

$('input.btn').click(function() {
  var submitBtn = $(this);
  submitBtn.attr('disabled', 'disabled');
  var wheel = $('#wheel');
  wheel.css('visibility', 'visible');
  var url = $('#url').val();
  
  if(/http:\/\/www.cuevana.tv/.exec(url)) {
    $('p.error').text('');
    fetchSources(url);
  } else if(/http:\/\/www.peliplay.com/.exec(url)) {
    $('p.error').text('');
    fetchSource(url);
  } else {
    showError('Streaming site unsupported!');
    submitBtn.removeAttr('disabled');
    wheel.css('visibility', 'hidden');
  }
});

$("a.link").live('click', function(e){
  $('input.btn').attr('disabled', 'disabled');
  $('#wheel').css('visibility', 'visible');
  var a = $(this);
  
  $.post('/cuevana', {def: a.data('def'), audio: a.data('audio'), host: a.data('host'), 
         id: a.data('id'), type: a.data('type')},
         function(data){window.location = data;});
  e.preventDefault();
});
