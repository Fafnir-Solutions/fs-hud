var Voip = "Normal";
var Interval = undefined;

function Minimal(Seconds) {
    var Days = Math.floor(Seconds / 86400)
    Seconds = Seconds - Days * 86400
    var Hours = Math.floor(Seconds / 3600)
    Seconds = Seconds - Hours * 3600
    var Minutes = Math.floor(Seconds / 60)
    Seconds = Seconds - Minutes * 60

    const [D, H, M, S] = [Days, Hours, Minutes, Seconds].map(s => s.toString().padStart(2, 0))

    if (Days > 0) {
        return D + ":" + H
    } else if (Hours > 0) {
        return H + ":" + M
    } else if (Minutes > 0) {
        return M + ":" + S
    } else if (Seconds > 0) {
        return "00:" + S
    }
}

const FormatNumber = n => {
    var n = n.toString();
    var r = "";
    var x = 0;

    for (var i = n["length"]; i > 0; i--) {
        r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? "." : "");
        x = x == 2 ? 0 : x + 1;
    }

    return r.split("").reverse().join("");
}

function GetTime() {
    let date = new Date();
    let hour = date.getHours().toString().length == 1 ? `0${date.getHours()}` : date.getHours();
    let minute = date.getMinutes().toString().length == 1 ? `0${date.getMinutes()}` : date.getMinutes();
    return `${hour}:${minute}`;
}

$(document).ready(function () {
    const messageHistory = [];
    let chatTimeout;
    let oldMessages = [];
    let oldMessagesIndex = -1;
    let blockedWords = [];
    let isEmojiPanelOpen = false;
    let isInputFocused = false;
    let isMuted = false;

    function cleanupEventListeners() {
        $('#input').off('keyup focus blur');
        $('#emojiButton').off('click');
        $('#muteButton').off('click');
        $('#emojiPanel').off('click', '.emoji');
        $(document).off('click.emojiPanel keyup.chat');
    }

    function initializeEventListeners() {
        cleanupEventListeners();

        $('#input').on('focus', function () {
            isInputFocused = true;
            clearTimeout(chatTimeout);
        });

        $('#input').on('blur', function () {
            isInputFocused = false;
            if (!isEmojiPanelOpen) {
                startCloseTimeout();
            }
        });

        $('#input').on('keyup', function (e) {
            if (e.which === 27) {
                closeChat();
                return;
            }

            if (e.which === 13) {
                const message = $(this).val();
                if (message.length > 0) {
                    if (checkBlockedWords(message)) {
                        $.post(`https://${GetParentResourceName()}/ChatSubmit`, JSON.stringify({ message: message, tag: "global" }));
                        oldMessages.unshift(message);
                        if (message.startsWith('/')) {
                            startCloseTimeout();
                        }
                    }
                    $(this).val('');
                } else {
                    closeChat();
                }
            }

            if (e.which === 38) {
                UsedCommands(true)
            }

            if (e.which === 40) {
                UsedCommands(false)
            }
        });

        $(document).on('keyup.chat', function (e) {
            if (e.which === 27) {
                if (isEmojiPanelOpen) {
                    closeEmojiPanel();
                    $('#input').focus();
                } else {
                    closeChat();
                }
            }
        });

        $('#emojiButton').on('click', function () {
            toggleEmojiPanel();
        });

        $('#muteButton').on('click', function () {
            toggleMute();
        });

        $('#emojiPanel').on('click', '.emoji', function () {
            const emoji = $(this).text();
            const cursorPos = $('#input')[0].selectionStart;
            const currentText = $('#input').val();
            const newText = currentText.slice(0, cursorPos) + emoji + currentText.slice(cursorPos);
            $('#input').val(newText);
            closeEmojiPanel();
            $('#input').focus();
        });

        $(document).on('click.emojiPanel', function (e) {
            if (!$(e.target).closest('.emoji-panel, #emojiButton').length && isEmojiPanelOpen) {
                closeEmojiPanel();
                $('#input').focus();
            }
        });
    }

    function startCloseTimeout() {
        clearTimeout(chatTimeout);
        chatTimeout = setTimeout(() => {
            if (!isInputFocused && !isEmojiPanelOpen) {
                closeChat();
            }
        }, 5000);
    }

    function toggleEmojiPanel() {
        isEmojiPanelOpen = !isEmojiPanelOpen;
        $('#emojiPanel').css('display', isEmojiPanelOpen ? 'grid' : 'none');
        $('#emojiButton').toggleClass('active');
        if (isEmojiPanelOpen) {
            clearTimeout(chatTimeout);
        } else {
            if (!isInputFocused) {
                startCloseTimeout();
            }
        }
    }

    function closeEmojiPanel() {
        if (isEmojiPanelOpen) {
            $('#emojiPanel').hide();
            $('#emojiButton').removeClass('active');
            isEmojiPanelOpen = false;
            if (!isInputFocused) {
                startCloseTimeout();
            }
        }
    }

    function toggleMute() {
        isMuted = !isMuted;
        const $button = $('#muteButton');

        if (isMuted) {
            $button.addClass('muted');
            $button.html('<i class="fa-solid fa-bell-slash"></i>');
            localStorage.setItem('chatMuted', 'true');
            $('.message:not(.system)').addClass('muted');
        } else {
            $button.removeClass('muted');
            $button.html('<i class="fa-solid fa-bell"></i>');
            localStorage.setItem('chatMuted', 'false');
            $('.message').removeClass('muted');
        }
    }

    function loadMuteState() {
        const savedMute = localStorage.getItem('chatMuted');
        if (savedMute === 'true') {
            toggleMute();
        }
    }

    function closeChat() {
        $('#app').fadeOut(500, function () {
            $(this).css('display', 'none');
            $('#input').val('').blur();
            closeEmojiPanel();
            isInputFocused = false;
        });
        $.post(`https://${GetParentResourceName()}/close`);
    }

    function addMessage(author, message, mode) {
        const $messages = $('#messages');
        const categories = {
            global: "GLOBAL",
            staff: "STAFF",
            police: "POLICIA",
            hospital: "HOSPITAL",
            mechanic: "MECANICO",
            system: "SISTEMA"
        };

        const category = categories[mode] || mode.toUpperCase();
        const isCommand = message.startsWith('/');
        const shouldMute = isMuted && mode !== 'system' && !isCommand;

        const messageHtml = `
            <div class="message ${mode} ${shouldMute ? 'muted' : ''}">
                <div class="message-header">
                    <span class="category">${category}</span>
                    <span class="name">${author}:</span>
                    <span class="time">${GetTime()}</span>
                </div>
                <span class="message-text" ${isCommand ? 'data-command="true"' : ''}>${message}</span>
            </div>`;

        messageHistory.push({ author, message, mode });
        $messages.prepend(messageHtml);

        if (!isMuted) {
            clearTimeout(chatTimeout);
            $('#app').css('display', 'flex').show();
            $('#input').focus();

            if (!$('#input').is(':focus')) {
                clearTimeout(chatTimeout);
                chatTimeout = setTimeout(() => {
                    closeChat();
                }, 5000);
            }
        }

        if (messageHistory.length > 50) {
            messageHistory.shift();
            $messages.children().last().remove();
        }
    }

    function checkBlockedWords(message) {
        const words = message.toLowerCase().split(' ');
        return !words.some(word => blockedWords.includes(word));
    }

    function UsedCommands(Up) {
        if (Up && oldMessages.length > oldMessagesIndex + 1) {
            oldMessagesIndex += 1;
            $('#input').val(oldMessages[oldMessagesIndex])
        } else if (!Up && oldMessagesIndex - 1 >= 0) {
            oldMessagesIndex -= 1;
            $('#input').val(oldMessages[oldMessagesIndex])
        } else if (!Up && oldMessagesIndex - 1 === -1) {
            oldMessagesIndex = -1;
            $('#input').val('')
        }
    }

    loadMuteState();
    const loadEmojis = () => {
        const $emojiPanel = $('#emojiPanel');
        $emojiPanel.empty();
        emojiList.forEach(emoji => {
            const $emoji = $('<div>').addClass('emoji').text(emoji);
            $emojiPanel.append($emoji);
        });
    };
    loadEmojis();

    window.addEventListener("message", function (event) {
        switch (event.data.Action) {
            case "Frequency":
                $(".Radio").html(event.data.Frequency);
                break;

            case "Body":
                if (event.data.Status) {
                    if ($(".DisplayHud").css("display") === "none") {
                        $(".DisplayHud").fadeIn(1000);
                    }
                } else {
                    if ($(".DisplayHud").css("display") === "flex") {
                        $(".DisplayHud").fadeOut(1000);
                    }
                }
                break;

            case "Passport":
                $(".Passport").html(FormatNumber(event.data.Number));
                break;

            case "Gemstone":
                $(".Gemstone").html(FormatNumber(event.data.Number));
                break;

            case "Clock":
                var Hours = event.data.Hours;
                var Minutes = event.data.Minutes;

                if (Hours <= 9)
                    Hours = "0" + Hours;
                if (Minutes <= 9)
                    Minutes = "0" + Minutes;

                $(".Clock").html(Hours + ":" + Minutes);
                break;

            case "Voice":
                const status = event["data"]["Status"];
                $("#microfone").css("background", event["data"]["Status"]);
            break;

            case "Voip":
                if (event.data.Voip === "Baixo") {
                    $(".Voice.one").css("background-color", "#ffffff");
                    $(".Voice.two, .Voice.three").css("background-color", "#ffffff3d");
                } else if (event.data.Voip === "Normal") {
                    $(".Voice.one, .Voice.two").css("background-color", "#ffffff");
                    $(".Voice.three").css("background-color", "#ffffff3d");
                } else if (event.data.Voip === "Alto") {
                    $(".Voice.one, .Voice.two, .Voice.three").css("background-color", "#ffffff");
                }
                break;

            case 'Health':
                $(".status-rect.health").css("height", event.data.Number + "%");
            break;

            case "Armour":
                if (event.data.Number > 0) {
                    if ($("#Armour-box").css("display") === "none") {
                        $("#Armour-box").fadeIn(1000);
                    }
                    $(".status-rect.armour").css("height", event.data.Number + "%");
                } else {
                    if ($("#Armour-box").css("display") === "flex") {
                        $("#Armour-box").fadeOut(1000);
                    }
                }
                break;

            case "Hunger":
                $(".status-rect.hunger").css("height", event.data.Number + "%");
                break;

            case "Thirst":
                $(".status-rect.thirst").css("height", event.data.Number + "%");
                break;

            case "Stress":
                if (event.data.Number > 0) {
                    if ($("#Stress-box").css("display") === "none") {
                        $("#Stress-box").fadeIn(1000);
                    }
                    $(".status-rect.stress").css("height", event.data.Number + "%");
                } else {
                    if ($("#Stress-box").css("display") === "flex") {
                        $("#Stress-box").fadeOut(1000);
                    }
                }
                break;

            case "Oxigen":
                if (event.data.Number < 100) {
                    if ($("#Oxigen-box").css("display") === "none") {
                        $("#Oxigen-box").fadeIn(1000);
                    }
                    $(".status-rect.oxigen").css("height", Math.floor(event.data.Number) + "%");
                } else {
                    if ($("#Oxigen-box").css("display") === "block") {
                        $("#Oxigen-box").fadeOut(1000);
                    }
                }
                break;

            case "Vehicle":
                if (event.data.Status) {
                    if ($("#car-container").css("display") === "none") {
                        $("#car-container").fadeIn(1000);

                        $("#Infos2").animate({ left: '17.5vw'}, 700);
                    }
                } else {
                    if ($("#car-container").css("display") === "block") {
                        $("#car-container").fadeOut(1000);
                    }
                    $("#Infos2").animate({ left: '1.5vw'}, 700);
                }
                break;

            case "Engine":
                const Engine = document.querySelector('.circle.engine');

                if (event.data.Number < 25) {
                    Engine.classList.add('red');
                } else if (event.data.Number < 75) {
                    Engine.classList.add('yellow');
                } else {
                    Engine.classList.add('green');
                }
            break;

            case "Notify":
                if (!$('.notify-container').length) {
                    $('body').prepend('<div class="notify-container"></div>');
                }
    
                const NotifyTypes = {
                    verde: {
                        icon: './images/success-icon.svg',
                        type: 'Sucesso'
                    },
                    amarelo: {
                        icon: './images/warn-icon.svg',
                        type: 'Aviso'
                    },
                    vermelho: {
                        icon: './images/error-icon.svg',
                        type: 'Negado'
                    },
                    azul: {
                        icon: './images/primary-icon.svg',
                        type: 'Importante'
                    }
                };
    
                if (event["data"]["css"]) {
                    const Timer = event["data"]["length"] || 3500;
                    const notifyType = NotifyTypes[event["data"]["css"]] || NotifyTypes.azul;
                    
                    const $notification = $('.notification.template').clone(true, true);
                    $notification.removeClass('template');
                    $notification.addClass(event["data"]["css"]);
                    $notification.find('img').attr('src', notifyType.icon);
                    $notification.find('.type').text(notifyType.type);
                    $notification.find('span').html(event["data"]["text"] || 'Notification');
                    
                    $notification.css({ display: 'flex', opacity: 0 });
                    $('.notify-container').prepend($notification);
                    $notification.fadeTo(300, 1);
                    
                    const $progressBar = $notification.find('.progress-bar');
                    $progressBar.css({
                        transition: `transform ${Timer}ms linear`,
                        transform: 'scaleX(0)'
                    });
                    
                    setTimeout(function() {
                        $notification.animate({
                            opacity: 0,
                            marginRight: '-100%'
                        }, 300, function() {
                            $(this).remove();
                        });
                    }, Timer);
                }
            break;

            case "Fuel":
                $(".fuel-fill").css("width", event.data.Number + "%");
                break;

            case 'Speed':
                let speedNumber = Math.floor(event.data.Number);

                if (speedNumber < 10) {
                    speedNumber = "00" + speedNumber;
                } else if (speedNumber < 100) {
                    speedNumber = "0" + speedNumber;
                }

                event.data.Number = speedNumber;

                const Rpm = $('.speed-segment');
                const totalRpm = Rpm.length;
                const RpmValue = 200 / totalRpm;

                Rpm.each(function (index) {
                    const reverseIndex = totalRpm - index - 1;
                    const segmentThreshold = (reverseIndex + 1) * RpmValue;

                    if (event.data.Number <= reverseIndex * RpmValue) {
                        $(this).removeClass('hidden').css({ 'opacity': '0.5', 'background-color': '#000000' });
                    } else if (event.data.Number < segmentThreshold) {
                        const opacity = 1 - ((event.data.Number - (reverseIndex * RpmValue)) / RpmValue);
                        $(this).removeClass('hidden').css({ 'opacity': opacity * 0.5, 'background-color': '#000000' });
                    } else {
                        $(this).removeClass('hidden').css({ 'opacity': '1', 'background-color': '' });
                    }
                });

                $("#speed").html(speedNumber);
                break;

            case "Rpm":
                var rpmvalue = (event.data.Number * 18)
                $(".gear").html(event.data.Gear);
                break;

            case "Seatbelt":
                const seatbeltCircle = document.querySelector('.circle.seatbelt');
                if (!event.data.Status) {
                    seatbeltCircle.classList.remove('green');
                    seatbeltCircle.classList.add('red');
                } else {
                    seatbeltCircle.classList.remove('red');
                    seatbeltCircle.classList.add('green');
                }
                break;

            case "Headlight":
                const headlightCircle = document.querySelector('.circle.headlight');

                if (event.data.Status === 0) {
                    headlightCircle.classList.remove('green', 'blue');
                    headlightCircle.classList.add('red');
                } else {
                    if (event.data.Beam === 0) {
                        headlightCircle.classList.remove('red', 'blue');
                        headlightCircle.classList.add('green');
                    } else {
                        headlightCircle.classList.remove('red', 'green');
                        headlightCircle.classList.add('blue');
                    }
                }
                break;

            case "Weapons":
                if (event.data.Status) {
                    if ($("#Weapon").css("display") === "none") {
                        $("#Weapon").fadeIn(1000);
                    }

                    $("#weapon-model").html(event.data.Name);
                    $("#ammo").html(event.data.Min);
                    $("#full-ammo").html(event.data.Max);

                    if (event.data.Min < 10) {
                        $("#ammo").css("color", "#fc5858");
                    } else if (event.data.Min < 15) {
                        $("#ammo").css("color", "#fcc458");
                    } else {
                        $("#ammo").css("color", "#ccc");
                    }
                } else {
                    if ($("#Weapon").css("display") === "block") {
                        $("#Weapon").fadeOut(1000);
                    }
                }
                break;

            case 'Chat':
                blockedWords = event.data.Block;
                clearTimeout(chatTimeout);
                $('#app').css('display', 'flex').show();
                $('#input').focus();
                initializeEventListeners();
                break;

            case 'Message':
                const [author, message, mode] = event.data.payload;
                addMessage(author, message, mode);
                break;

            case 'Clear':
                oldMessages = [];
                oldMessagesIndex = -1;
                $('#messages').children().remove();
                break;
        }
    });
});