function Chat(host) {
    var chat = this;
    hostname = host;
    loginname = "";
    
    array = [];
    
    disconnectflg = false;;
    reconnectflg = false;

    chat.ws = new WebSocket('wss://' + host);
    chat.ws.onopen = function() {
        console.log("onopen");
        chat.askUsername();
    };

    chat.askUsername = function() {
        loginname = prompt('ユーザー名を入力して下さい。');

        $.get('https://api.github.com/users/' + loginname, function(data) {
            chat.join(loginname);
        }).fail(function() {
            alert('Invalid username');
            chat.askUsername();
        });
    }

    chat.imageCache = {};

    $('form').on('submit', function(e) {
        e.preventDefault();

        var message = $('.message-input').val();

        if (message.length == 0 || message.length >= 256) {
            return;
        }
                 console.log("send:" + message);
                 
        chat.send(message);
        $('.message-input').val('');
    });

    
    $(window).on("beforeunload", function(e) {
                 disconnectflg = true;
                 chat.ws.send(JSON.stringify({
                                             'message': 'disconnect'
                                             }));
                 
                 
                 
//                 chat.ws.close();
                 console.log("beforeunload close");
//                 alert('切断します');
                 return ;
                 });
 
    
    $(window).on("unload", function(e) {
//                 chat.ws.send(JSON.stringify({
//                                             'message': 'disconnect'
//                                             }));
//
                 
                 
                 //                 chat.ws.close();
                 console.log("unload");
                 //                 alert('切断します');
//                 return "切断します";
                 });
    
    
    
    chat.ws.onmessage = function(event) {
        console.log("data=" + event.data);
        if (event.data == 'disconnect') {
            console.log("disconnect");
            chat.ws.close();
        } else if (event.data == '__ping__') {
            console.log("ping");
            chat.ws.send(JSON.stringify({
                 'message': '__pong__'
            }));
        } else {
          var message = JSON.parse(event.data);
//        console.log('[' + name + '] ' + message);
          chat.bubble(message.message, message.username);
        }
    }

   
    chat.ws.onclose = function (e) {
        console.log("Close Code = " + e.code);
        console.log("Close Reason = " + e.reason);
        if (disconnectflg == false) {
            console.log("reconnet start");
            chat.ws = null;
            chat.reconnect();
//            setTimeout(chat.reconnect, 2000);
        }
    }

    chat.reconnect = function() {
        reconnectflg = true;
        console.log("reconnet method");
        chat.ws = new WebSocket('wss://' + hostname);
        chat.ws.onopen = function() {
            console.log("onopen");
//            chat.askUsername();
            chat.join(loginname);
        };
        chat.ws.onmessage = function(event) {
            console.log("data=" + event.data);
            if (event.data == 'disconnect') {
                console.log("disconnect")
                chat.ws.close();
            } else {
                var message = JSON.parse(event.data);
                //        console.log('[' + name + '] ' + message);
                chat.bubble(message.message, message.username);
            }
        };
        chat.ws.onclose = function (e) {
            console.log("Close Code = " + e.code);
            console.log("Close Reason = " + e.reason);
            if (disconnectflg == false) {
                console.log("reconnet start");
                chat.ws = null;
                chat.reconnect();
                //            setTimeout(chat.reconnect, 2000);
            }
        };

    }
            
    
    chat.send = function(message) {
        if ( chat.ws.readyState === WebSocket.OPEN ) {
//            chat.ws.send(JSON.stringify({
//            'message': message
//            }));
//            chat.bubble(message);
            chat.sendmessage(message);
        } else {
            console.log("ready state:" + chat.ws.readyState);
            setTimeout(function(){chat.sendmessage(message)}, 3000);
        }
    }

    chat.sendmessage = function(message) {
        console.log("send message:" + message);
        chat.ws.send(JSON.stringify({
                                    'message': message
                                    }));
        chat.bubble(message);
    }
    
    
    chat.bubble = function(message, username) {
        var bubble = $('<div>')
            .addClass('message')
            .addClass('new');

        if (username) {
            
            if (reconnectflg == true && message.indexOf(loginname) == 0) {
                console.log("reonnect bot skip:" + message);
                return;
            }
            

            
            var lookup = username;

            if (lookup == 'Bot') {
                
                
                
                
                
                if (message.indexOf(loginname) < 0) {
                    var start = message.indexOf("が参加しました。");
                    var end = message.indexOf("が退出しました。");
                    var u = "";
                    if (start >0) {
                        u = message.substr(0,start);
                        if (array.indexOf(u) < 0) {
                            array.push(u);
                            console.log(u + " push");
                        } else {
                            console.log(u + " exist return");
                            return;
                        }
                    }
                    if (end >0) {
                        u = message.substr(0,end);
                        if (array.indexOf(u) >= 0) {
                            array.splice( array.indexOf(u), 1 );
                            console.log(u + " del");
                        }
                    }
                    console.log("u=" + u);
                    //                if (array.indexOf(message))
                }
                
                
                
                
                
                
                lookup = 'qutheory';
            }
            bubble.attr('data-username', lookup);

            var imageUrl = chat.imageCache[lookup];

            if (!imageUrl) {
                // async fetch and update the image
                $.get('https://api.github.com/users/' + lookup, function(data) {
                    if (data.avatar_url) {
                        imageUrl = data.avatar_url;
                    } else {
                        imageUrl = 'https://avatars3.githubusercontent.com/u/17364220?v=3&s=200';
                    }

                    $('div.message[data-username=' + lookup + ']')
                        .find('img')
                        .attr('src', imageUrl);

                    chat.imageCache[lookup] = imageUrl;
                });
            }

            var image = $('<img>')
                .addClass('avatar')
                .attr('src', imageUrl);

            bubble.append(image);
        }


        var text = $('<span>')
            .addClass('text');

        if (username) {
            text.text(username + ': ' + message);
        } else {
            bubble.addClass('personal');
            text.text(message);
        }


        bubble.append(text);

        var d = new Date()
        var m = '00'
        if (m != d.getMinutes()) {
            m = d.getMinutes();
        }

        if (m < 10) {
            m = '0' + m;
        }

        var time = $('<span class="timestamp">' + d.getHours() + ':' + m + '</div>');
        bubble.append(time);

        $('.messages').append(bubble);

        var objDiv = $('.messages')[0];
        objDiv.scrollTop = objDiv.scrollHeight;
    }

    chat.join = function(name) {
        console.log("join name=" + name);
        chat.ws.send(JSON.stringify({
            'username': name
        }));
    }
};
