var base_url = 'http://localhost:9090/';
var base_params = {};
var container = $('#div_main');
var currentFile = '';

function hideall(){
    $('.jumbotron, #div_score, #div_archive, #btn_back').hide();
}

function processMidi(data){
    if(!data.successful){
        alert('Error occurred!');
        console.log(data.result);
        return;
    }
    
    MIDI.loadPlugin({
    	instrument: "acoustic_grand_piano", // or "Acoustic Grand Piano"
    	callback: function() {
    		MIDI.noteOn(0, 100, 127, 0);
    		 MIDI.Player.loadFile("base64,"+data.result, function(){
    		     console.log("Loaded music file");
    		     $('#btn_play').prop('disabled', false);
    		 });
    	}
    });
}

function init(){
    hideall();
    $('.jumbotron').show();
    $('#btn_go').on('click', function(){
        sendRequest('listMusicFiles', 'processMusicList')
        });
    $('#btn_back').on('click', function(){
        console.log("back");
        try{
            MIDI.Player.stop();
        }catch(e){console.log("Music not playing")}
        hideall();
        $("#div_archive").show();
    })
    $('#div_main').on('click', 'a.music-filename', function(event){
        $('#modal_converting').modal('show');
        currentFile = $(event.target).text();
        sendRequest('musicScore/'+$(event.target).text(), 'processScore');
        $('#group_sound button').prop('disabled', true);
        sendRequest('musicScoreMidi', 'processMidi');
    }).on('click', '#btn_play', function(event){
        if(MIDI.Player.currentTime > 0)
            MIDI.Player.resume();
        else
            MIDI.Player.start();
        $('#btn_stop,#btn_pause').prop('disabled', false);
        $('#btn_play').prop('disabled', true);
    }).on('click', '#btn_pause', function(event){
        MIDI.Player.pause();
        $('#btn_play').prop('disabled', false);
        $('#btn_pause').prop('disabled', true);
    }).on('click', '#btn_stop', function(event){
        MIDI.Player.stop();
        $('#btn_stop,#btn_pause').prop('disabled', true);
        $('#btn_play').prop('disabled', false);
    });
    
    
    var opts = {
      lines: 13, // The number of lines to draw
      length: 20, // The length of each line
      width: 10, // The line thickness
      radius: 30, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 0, // The rotation offset
      direction: 1, // 1: clockwise, -1: counterclockwise
      color: '#000', // #rgb or #rrggbb or array of colors
      speed: 1, // Rounds per second
      trail: 60, // Afterglow percentage
      shadow: false, // Whether to render a shadow
      hwaccel: false, // Whether to use hardware acceleration
      className: 'spinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: 'auto', // Top position relative to parent in px
      left:'auto' // Left position relative to parent in px
    };
    
    var target = document.getElementById('searching_spinner_center');
    var spinner = new Spinner(opts).spin(target);
}

function processMusicList(data){
    hideall();
    if(!data.successful){
        alert('Error occurred!');
        console.log(data.result);
    }
    else{
         $('#heading').text('Music XML Archive');
         var archive = $('#div_archive').empty();
         $.each(data.result, function(i, filename){
            archive.append('<a class="music-filename list-group-item">'+filename+'</a>')
         });
         archive.show();
    }
}

function processScore(data){
    $('#modal_converting').modal('hide');
    hideall();
    $('#btn_back').show();
    if(!data.successful){
        alert('Error occurred!');
        console.log(data.result);
    }
    else{
         $('#heading').text(currentFile);
         $('#text_score').empty();
         $('#text_score').text(data.result.score);
         $('#tab_pdf').empty().append('<iframe src="http://localhost:9090/musicScorePdf?embedded=true" style="width:600px; height:500px;" frameborder="0"></iframe>');
         var detContainer = $('#div_details').empty();
         for (var key in data.result.details) {
             var val = data.result.details[key];
             if(val && val.length>0) {
                 detContainer.append('<div class="row">'+
                 '<div class="col-sm-4">'+'<strong>'+
                 key+'</strong>'+
                 '</div>'+
                 '<div class="col-sm-8">'+
                 val+
                 '</div>'+
                 '</div><hr/>');
             }
         }
         $('#div_score').show();
    }
}

function sendRequest(method, callbackName){
     $.ajax({
        type: 'GET',
        url: base_url+method+'?callback='+callbackName,
        dataType: 'jsonp'
    });
}

$(document).load(init());
