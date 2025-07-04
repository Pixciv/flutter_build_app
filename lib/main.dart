import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const BallsOfExplodeApp());
}

class BallsOfExplodeApp extends StatelessWidget {
  const BallsOfExplodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BallsGameWebView(),
    );
  }
}

class BallsGameWebView extends StatefulWidget {
  const BallsGameWebView({super.key});

  @override
  State<BallsGameWebView> createState() => _BallsGameWebViewState();
}

class _BallsGameWebViewState extends State<BallsGameWebView> {
  late final WebViewController _controller;

  final String htmlData = r'''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Balls of Explode</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Tomorrow:wght@600&display=swap" rel="stylesheet">
    <script src="https://code.createjs.com/1.0.0/soundjs.min.js"></script>
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css" integrity="sha384-oS3vJWv+0UjzBfQzYUhtDYW+Pj2yciDJxpsK1OYPAYjqT085Qq/1cq5FLXAZQ7Ay" crossorigin="anonymous">
    
    <style>
        body {
            padding: 0;
            margin: 0;
            overflow: hidden; /* Mobil cihazlarda istenmeyen kaydırmayı engeller */
            background-color: rgb(25, 25, 25);
            user-select: none;
            -webkit-user-select: none;
            font-family: 'Tomorrow', sans-serif;
            /* Dokunmatik cihazlarda tıklama gecikmesini azaltmak için */
            -ms-touch-action: manipulation;
            touch-action: manipulation;
            display: flex; /* Ana içeriği ortalamak için */
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: white;
        }

        /* index.html için özel stiller (başlangıç ekranı) */
        .title {
            margin: 20px 10px 30px;
            font-size: 1.8em;
            text-align: center;
            line-height: 1.2;
        }

        .upload-section {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 15px;
            margin-bottom: 25px;
            max-width: 95%;
            padding: 0 10px;
            box-sizing: border-box;
        }

        .upload-box {
            border: 2px dashed #ccc;
            border-radius: 10px;
            width: 120px;
            height: 120px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            background-color: rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }

        .upload-box:hover {
            border-color: #029DFF;
            background-color: rgba(255, 255, 255, 0.2);
        }

        .upload-box input[type="file"] {
            position: absolute;
            width: 100%;
            height: 100%;
            opacity: 0;
            cursor: pointer;
        }

        .upload-box img.preview {
            max-width: 100%;
            max-height: 100%;
            object-fit: cover;
            display: none;
            border-radius: 8px;
        }

        .upload-box .placeholder {
            font-size: 0.75em;
            text-align: center;
            color: #ccc;
            padding: 8px;
        }

        #start-button {
            padding: 12px 25px;
            font-size: 1.3em;
            background-color: #029DFF;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            opacity: 0.5;
            pointer-events: none;
            margin-top: 15px;
        }

        #start-button.active {
            background-color: #029DFF;
            opacity: 1;
            pointer-events: auto;
        }

        #start-button:hover.active {
            background-color: #017bbd;
        }

        .message {
            margin: 15px 10px 0;
            font-size: 0.95em;
            color: orange;
            text-align: center;
            line-height: 1.3;
        }

        @media (max-width: 480px) {
            .title {
                font-size: 1.6em;
            }
            .upload-box {
                width: 100px;
                height: 100px;
            }
            .upload-box .placeholder {
                font-size: 0.7em;
            }
            #start-button {
                font-size: 1.2em;
                padding: 10px 20px;
            }
            .message {
                font-size: 0.9em;
            }
        }

        /* indexpic.html ve style.css'ten gelen stiller */
        #gameContainer {
            display: none; /* Başlangıçta gizli tut */
            position: absolute;
            width: 100%; /* Mobil cihazlarda tam genişlik kullan */
            height: 100%; /* Mobil cihazlarda tam yükseklik kullan */
            box-shadow: 0 0 2px white;
        }

        #canvas {
            position: absolute;
            top: 0px;
            left: 50%; /* Canvas'ı yatayda ortala */
            transform: translateX(-50%); /* Canvas'ı yatayda ortala */
        }

        #Fps {
            position: absolute;
            right: 10px; /* Sağ kenara daha yakın */
            bottom: 10px; /* Alt kenara daha yakın */
            color: white;
            display: none; /* Oyun başladığında görünmez */
            flex-direction: row; /* inline yerine row kullanmak daha doğru */
            align-items: center;
            font-size: 0.5em; /* Daha küçük bir font boyutu */
            z-index: 2; /* Diğer elementlerin üzerinde görünmesini sağla */
        }

        #nbrfps {
            background-color: rgba(100, 100, 100, 0.2);
            width: 25px; /* Daha küçük boyut */
            height: 25px; /* Daha küçük boyut */
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            margin-left: 10px; /* Daha az boşluk */
            font-size: 1.2em; /* Yazı boyutunu ayarla */
        }

        #checkbowaudio {
            position: absolute;
            bottom: 20px; /* Alt kenara daha yakın */
            right: 15px; /* Sağ kenara daha yakın */
            color: white;
            font-size: 1.2em; /* Daha küçük bir ikon */
            z-index: 3;
        }

        #info {
            position: absolute;
            bottom: 20px; /* Ekranın altından 20 piksel yukarıda */
            left: 20px;  /* Ekranın solundan 20 piksel içeride */
            color: white;
            font-size: 1.5em;
            font-weight: bold;
            z-index: 10; /* Canvas'ın üzerinde görünmesini sağlar */
        }
        #endgame {
            position: absolute;
            width: 100%;
            height: 100%;
            color: white;
            display: none;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            -webkit-backdrop-filter: blur(10px);
            backdrop-filter: blur(10px);
            text-align: center;
            font-size: 2em; /* Oyun bitti yazısını biraz küçült */
            z-index: 4; /* En üstte görünmesini sağla */
        }

        #score {
            font-size: 0.8em;
        }

        #highScoreDisplay { /* Yeni eklenen yüksek skor göstergesi */
            font-size: 0.6em;
            margin-top: 10px;
            color: yellow; /* Yüksek skoru vurgulamak için renk */
            display: none; /* Başlangıçta gizli */
        }

        /* Küçük ekranlar için medya sorguları */
        @media (max-width: 768px) {
            #Fps {
                right: 5px;
                bottom: 5px;
                font-size: 0.45em;
            }

            #nbrfps {
                width: 20px;
                height: 20px;
                margin-left: 5px;
                font-size: 1em;
            }

            #checkbowaudio {
                bottom: 10px;
                right: 10px;
                font-size: 1.1em;
            }

            #info {
                font-size: 1.1em;
                left: 5px;
            }

            #endgame {
                font-size: 1.8em;
            }
        }

        @media (max-width: 480px) {
            #Fps {
                font-size: 0.4em;
            }

            #nbrfps {
                width: 18px;
                height: 18px;
                font-size: 0.9em;
            }

            #checkbowaudio {
                font-size: 1em;
            }

            #info {
                font-size: 1em;
            }

            #endgame {
                font-size: 1.6em;
            }
        }
    </style>
</head>
<body>
    <div id="selectionScreen">
        <div class="title">SELECT PHOTO OF YOUR BALLS</div>
        <div class="upload-section">
            <div class="upload-box" id="upload-box-0">
                <input type="file" accept="image/*" id="file-input-0">
                <img src="" alt="Image Preview" class="preview" id="preview-0">
                <div class="placeholder">1st Photo</div>
            </div>
            <div class="upload-box" id="upload-box-1">
                <input type="file" accept="image/*" id="file-input-1">
                <img src="" alt="Image Preview" class="preview" id="preview-1">
                <div class="placeholder">2nd Photo</div>
            </div>
            <div class="upload-box" id="upload-box-2">
                <input type="file" accept="image/*" id="file-input-2">
                <img src="" alt="Image Preview" class="preview" id="preview-2">
                <div class="placeholder">3rd Photo</div>
            </div>
            <div class="upload-box" id="upload-box-3">
                <input type="file" accept="image/*" id="file-input-3">
                <img src="" alt="Image Preview" class="preview" id="preview-3">
                <div class="placeholder">4th Photo</div>
            </div>
        </div>
        <button id="startButton">START GAME</button>
        <div class="message" id="errorMessage"></div>
    </div>

    <div id="gameContainer">
        <canvas id="canvas"></canvas>
        <span id="Fps"><i>FPS</i><span id="nbrfps"></span></span>
        <div id="info">0</div>
        <span id="checkbowaudio"><i class="fas fa-volume-up"></i></span>
        <div id="endgame">GAME OVER <br><br><span id="score"></span><br><span id="highScoreDisplay"></span></div>
    </div>

    <script>
        // Başlangıç ekranı için JavaScript
        const fileInputs = document.querySelectorAll('.upload-section input[type="file"]');
        const previews = document.querySelectorAll('.upload-section img.preview');
        const placeholders = document.querySelectorAll('.upload-section .placeholder');
        const startButton = document.getElementById('startButton');
        const errorMessage = document.getElementById('errorMessage');
        const selectionScreen = document.getElementById('selectionScreen');
        const gameContainer = document.getElementById('gameContainer');

        const selectedImages = [];
        const requiredImageCount = 4;

        const MAX_IMAGE_SIZE = 250;
        const IMAGE_QUALITY = 0.9;

        function checkAllImagesLoaded() {
            const loadedCount = selectedImages.filter(img => img !== undefined && img !== null && img !== '').length;
            if (loadedCount === requiredImageCount) {
                startButton.classList.add('active');
                errorMessage.textContent = '';
            } else {
                startButton.classList.remove('active');
                if (loadedCount < requiredImageCount) {
                    errorMessage.textContent = `Please upload ${requiredImageCount - loadedCount} more photos.`;
                }
            }
        }

        fileInputs.forEach((input, index) => {
            selectedImages[index] = null;
            input.addEventListener('change', function(event) {
                const file = event.target.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        const img = new Image();
                        img.onload = function() {
                            let width = img.width;
                            let height = img.height;

                            if (width > MAX_IMAGE_SIZE || height > MAX_IMAGE_SIZE) {
                                if (width > height) {
                                    height = Math.round(height * (MAX_IMAGE_SIZE / width));
                                    width = MAX_IMAGE_SIZE;
                                } else {
                                    width = Math.round(width * (MAX_IMAGE_SIZE / height));
                                    height = MAX_IMAGE_SIZE;
                                }
                            }

                            const canvas = document.createElement('canvas');
                            const ctx = canvas.getContext('2d');
                            canvas.width = width;
                            canvas.height = height;

                            ctx.drawImage(img, 0, 0, width, height);

                            let resizedBase64;
                            if (file.type === 'image/png') {
                                resizedBase64 = canvas.toDataURL('image/png');
                            } else {
                                resizedBase64 = canvas.toDataURL('image/jpeg', IMAGE_QUALITY);
                            }
                            
                            previews[index].src = resizedBase64;
                            previews[index].style.display = 'block';
                            placeholders[index].style.display = 'none';
                            selectedImages[index] = resizedBase64;
                            checkAllImagesLoaded();
                        };
                        img.src = e.target.result;
                    };
                    reader.readAsDataURL(file);
                } else {
                    previews[index].src = '';
                    previews[index].style.display = 'none';
                    placeholders[index].style.display = 'block';
                    selectedImages[index] = null;
                    checkAllImagesLoaded();
                }
            });
        });

        startButton.addEventListener('click', function() {
            if (startButton.classList.contains('active')) {
                try {
                    localStorage.setItem('gameImages', JSON.stringify(selectedImages));
                    // Oyunu başlatmak için ekranları değiştir
                    selectionScreen.style.display = 'none';
                    gameContainer.style.display = 'block'; // Veya 'flex'/'grid' gibi uygun bir display değeri
                    initGameAssets(); // Oyunun başlatma fonksiyonunu çağır
                } catch (e) {
                    if (e instanceof DOMException && e.name === 'QuotaExceededError') {
                        errorMessage.textContent = "Images are too large! Please try smaller sized images.";
                        errorMessage.style.color = 'red';
                    } else {
                        errorMessage.textContent = "An error occurred: " + e.message;
                        errorMessage.style.color = 'red';
                    }
                    console.error("LocalStorage error:", e);
                }
            }
        });

        checkAllImagesLoaded();

        // Oyunun JavaScript kodu buraya gelecek
        let c, ctx, W, H;
        let gamePlay = true;
        let dots = [], booms = [], same = [];
        let rad, diam;
        let gameImages = [];
        let player, nbrPlayer = 0;
        let mouse, touch;
        let lastTimeCalled;
        let countPoints = 0, lineEndY = 0, nbrBallsLevel = 4, progress = 0;
        let checkBoxAudio = true, effetBigBoom = false, move = false;

        const srcSoundSelect = "https://lolofra.github.io/balls/audio/selected.mp3";
        const srcSoundBoom = "https://lolofra.github.io/balls/audio/sbomb.mp3";
        const srcSoundEnd = "https://lolofra.github.io/balls/audio/end.mp3";
        const srcSoundBigBoom = "https://lolofra.github.io/balls/audio/bigBoom.mp3";

        let lastPoppedImageMq = -1;
        let consecutivePops = 0;

        let noBoomStreak = 0;
        const NO_BOOM_THRESHOLD = 2;
        const SLIDE_AMOUNT_PER_ROW = diam * Math.sqrt(3) / 2;
        const SLIDE_INCREMENT_PER_FRAME = 2;
        let slidingInProgress = false;

        const random = (max=1, min=0) => Math.random() * (max - min) + min;

        const calcFPS = () => {
            let dt = performance.now() - lastTimeCalled;
            lastTimeCalled = performance.now();
            const nbrfpsElement = document.getElementById("nbrfps");
            if (nbrfpsElement) {
                nbrfpsElement.innerText = Math.round(1000 / dt);
            }
        };

        const FRAME_COLORS = [
            '#FFFF00', // Yellow
            '#00FFFF', // Cyan
            '#FF00FF', // Magenta
            '#00FF00'  // Green
        ];

        const getFrameColor = (imageIndex) => {
            return FRAME_COLORS[imageIndex % FRAME_COLORS.length];
        };

        class DotS{
            constructor(x,y,rad,mq){
                this.x = x;
                this.y = y;
                this.rad = rad;
                this.mq = mq;
            }
        }

        class Dot extends DotS{
            constructor(x,y,rad,mq,boom) {
                super(x,y,rad,mq);
                this.boom = boom || false;
                this.nextY = y;
                this.isolate = false;
                this.speed = 0.7;
                this.borderColor = getFrameColor(this.mq);
            }
            fall() {
                if(this.isolate) {
                    this.y += this.speed;
                } else if (this.y < this.nextY) {
                    this.y = Math.min(this.nextY, this.y + SLIDE_INCREMENT_PER_FRAME);
                } else if (this.y > this.nextY) {
                    this.y = Math.max(this.nextY, this.y - SLIDE_INCREMENT_PER_FRAME);
                }
            }
            draw() {
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                ctx.fillStyle = 'rgba(0,0,0,0.5)';
                ctx.fill();
                ctx.closePath();

                if (gameImages[this.mq] && gameImages[this.mq].complete) {
                    ctx.save();
                    ctx.clip();
                    ctx.drawImage(
                        gameImages[this.mq],
                        this.x - this.rad,
                        this.y - this.rad,
                        this.rad * 2,
                        this.rad * 2
                    );
                    ctx.restore();
                } else {
                    ctx.beginPath();
                    ctx.fillStyle = this.borderColor;
                    ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                    ctx.fill();
                    ctx.closePath();
                    ctx.font = `${this.rad * 0.8}px Arial`;
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillStyle = 'black';
                    ctx.fillText('?', this.x, this.y);
                }
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                ctx.strokeStyle = this.borderColor;
                ctx.lineWidth = 2;
                ctx.stroke();
                ctx.closePath();
            }
            update() {
                this.fall();
                this.draw();
            }
        }

        class Player extends DotS{
            constructor(x,y,rad,mq) {
                super(x,y,rad,mq);
                this.play = false;
                this.run = false;
                this.t = 0;
                this.borderColor = getFrameColor(this.mq);
                this.trail = [];
                this.trailMaxLength = 20;
            }
            update() {
                if (this.run) {
                    this.trail.push({x: this.x, y: this.y, rad: this.rad});
                    if (this.trail.length > this.trailMaxLength) {
                        this.trail.shift();
                    }
                } else {
                    this.trail = [];
                }

                for (let i = 0; i < this.trail.length; i++) {
                    const trailDot = this.trail[i];
                    const ratio = i / this.trail.length;
                    const alpha = ratio * 0.7;
                    const sizeReduction = (1 - ratio) * 0.7;

                    ctx.beginPath();
                    ctx.arc(trailDot.x, trailDot.y, trailDot.rad * (1 - sizeReduction), 0, 2 * Math.PI);
                    ctx.fillStyle = `rgba(255, 255, 255, ${alpha})`;
                    ctx.fill();
                    ctx.closePath();
                }

                ctx.beginPath();
                ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                ctx.fillStyle = 'rgba(0,0,0,0.5)';
                ctx.fill();
                ctx.closePath();

                if (gameImages[this.mq] && gameImages[this.mq].complete) {
                    ctx.save();
                    ctx.clip();
                    ctx.drawImage(
                        gameImages[this.mq],
                        this.x - this.rad,
                        this.y - this.rad,
                        this.rad * 2,
                        this.rad * 2
                    );
                    ctx.restore();
                } else {
                    ctx.beginPath();
                    ctx.fillStyle = this.borderColor;
                    ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                    ctx.fill();
                    ctx.closePath();
                    ctx.font = `${this.rad * 0.8}px Arial`;
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillStyle = 'black';
                    ctx.fillText('?', this.x, this.y);
                }
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                ctx.strokeStyle = this.borderColor;
                ctx.lineWidth = 2;
                ctx.stroke();
                ctx.closePath();
            }
        }

        class Boom {
            constructor(x,y,rad,mq) {
                this.x = x;
                this.y = y;
                this.rad = rad;
                this.mq = mq;
                this.a = random(2 * Math.PI);
                this.color = `rgba(255,255,255,${random(0.5, 0.2)})`;
            }
            draw() {
                ctx.beginPath();
                ctx.fillStyle = this.color;
                ctx.arc(this.x, this.y, this.rad, 0, 2 * Math.PI);
                ctx.fill();
                ctx.closePath();
            }
            update() {
                this.x += 2 * Math.cos(this.a);
                this.y += 2 * Math.sin(this.a);
                this.rad -= 0.5;
                this.draw();
            }
        }

        const eventsListener = () => {
            mouse = { x: null, y: null };
            touch = { x: null, y: null };

            c.addEventListener("mousemove", function(event){
                event.preventDefault();
                if(move){
                    mouse.x = event.clientX;
                    mouse.y = event.clientY;
                } else {
                    mouse.x = null;
                    mouse.y = null;
                }
            });
            c.addEventListener("mousedown", function(event){
                event.preventDefault();
                move=true;
                mouse.x = event.clientX;
                mouse.y = event.clientY;
            });
            c.addEventListener("mouseup", function(event){
                event.preventDefault();
                if(player.play === false) {
                    player.run = true;
                    player.play = true;
                    let dx = player.x - mouse.x;
                    let dy = player.y - mouse.y;
                    let t = Math.atan2(-dy, -dx);
                    player.t = t;
                }
                move=false;
                mouse.x = null;
                mouse.y = null;
            });
            c.addEventListener("touchstart", function(event){
                event.preventDefault();
                let touchEvent = event.changedTouches[0];
                mouse.x = touchEvent.clientX - c.getBoundingClientRect().left;
                mouse.y = touchEvent.clientY - c.getBoundingClientRect().top;
                move=true;
            });
            c.addEventListener("touchmove", function(event){
                event.preventDefault();
                if(move){
                    let touchEvent = event.changedTouches[0];
                    mouse.x = touchEvent.clientX - c.getBoundingClientRect().left;
                    mouse.y = touchEvent.clientY - c.getBoundingClientRect().top;
                }
            });
            c.addEventListener("touchend", function(event){
                event.preventDefault();
                if(player.play === false){
                    player.run = true;
                    player.play = true;
                    let dx = player.x - mouse.x;
                    let dy = player.y - mouse.y;
                    let t = Math.atan2(-dy, -dx);
                    player.t = t;
                }
                mouse.x = null;
                mouse.y = null;
                move=false;
            });
            const checkbowaudioElement = document.getElementById("checkbowaudio");
            if (checkbowaudioElement) {
                if (checkBoxAudio) {
                    checkbowaudioElement.innerHTML = `<i class="fas fa-volume-up"></i>`;
                } else {
                    checkbowaudioElement.innerHTML = `<i class="fas fa-volume-mute"></i>`;
                }

                checkbowaudioElement.addEventListener("click", function(){
                    checkBoxAudio = checkBoxAudio ? false: true;
                    if(checkBoxAudio){
                        this.innerHTML = `<i class="fas fa-volume-up"></i>`;
                    }
                    else{
                        this.innerHTML = `<i class="fas fa-volume-mute"></i>`;
                    }
                });
            }

            window.addEventListener('resize', initWidthHeight);
        };

        const checkColor = () => {
            let queue = [];
            let visited = new Set();
            same = [];

            if (dots.length > 0) {
                let newlyAddedDot = dots[dots.length - 1];

                if (!visited.has(newlyAddedDot)) {
                    queue.push(newlyAddedDot);
                    visited.add(newlyAddedDot);
                    newlyAddedDot.boom = true;
                }
            }

            let head = 0;
            while (head < queue.length) {
                let currentDot = queue[head++];

                for (let i = 0; i < dots.length; i++) {
                    let neighborDot = dots[i];

                    if (currentDot !== neighborDot &&
                        currentDot.mq === neighborDot.mq &&
                        !visited.has(neighborDot)) {

                        let d0 = Math.hypot(currentDot.x - neighborDot.x, currentDot.y - neighborDot.y);
                        if (d0 < (currentDot.rad + neighborDot.rad) * 1.05) {
                            queue.push(neighborDot);
                            visited.add(neighborDot);
                            neighborDot.boom = true;
                        }
                    }
                }
            }
            same = Array.from(visited);
        };

        const getNearestHexPosition = (x, y) => {
            const rowHeight = diam * Math.sqrt(3) / 2;
            const colWidth = diam;

            let approxRow = (y - rad) / rowHeight;
            let targetRow = Math.round(approxRow);

            let rowOffset = (targetRow % 2 === 0) ? 0 : rad;

            let approxCol = (x - rad - rowOffset) / colWidth;
            let targetCol = Math.round(approxCol);

            let nearestX = rad + targetCol * colWidth + rowOffset;
            let nearestY = rad + targetRow * rowHeight;

            return { x: nearestX, y: nearestY };
        };

        const checkPlayer = () => {
            checkEndGame();
            if(player.run){
                let hitOccurred = false;

                if (player.y <= rad) {
                    player.run = false;
                    hitOccurred = true;

                    let {x: newDotX, y: newDotY} = getNearestHexPosition(player.x, rad);

                    dots.push(new Dot(newDotX, newDotY, rad, player.mq, false));
                    player.y = -H/2;

                    same = [];
                    dots[dots.length - 1].boom = true;
                    same.push(dots[dots.length - 1]);

                    checkColor();

                    let cpt = same.length;

                    if (cpt >= 5) {
                        handleBoomEffect(cpt, same[0].mq);
                        noBoomStreak = 0;
                    } else {
                        for(let i = 0; i < same.length; i++){
                            same[i].boom = false;
                        }
                        if(checkBoxAudio) createjs.Sound.play('soundball');
                        lastPoppedImageMq = -1;
                        consecutivePops = 0;
                        noBoomStreak++;
                        if (!slidingInProgress) {
                            handleNoBoomEffect();
                        }
                    }

                    handleNextPlayerAndRow();
                }

                if (player.x - player.rad < 0) {
                    player.x = player.rad;
                    player.t = Math.PI - player.t;
                }
                else if (player.x + player.rad > W) {
                    player.x = W - player.rad;
                    player.t = Math.PI - player.t;
                }
                else if (player.y + player.rad > H - rad * 2) {
                    player.y = H - rad * 2 - player.rad;
                    player.t = 2 * Math.PI - player.t;
                }

                if (!hitOccurred) {
                    for(let i = 0; i < dots.length; i++){
                        if (dots[i].boom) continue;

                        let d0 = Math.hypot(player.x - dots[i].x, player.y - dots[i].y );

                        const collisionThreshold = (player.rad + dots[i].rad) * 0.95;

                        if(d0 < collisionThreshold) {
                            player.run = false;
                            hitOccurred = true;

                            let bestPosition = null;
                            let minDistance = Infinity;

                            const hexOffsets = [
                                {dx: 0, dy: -diam * Math.sqrt(3) / 2},
                                {dx: diam * 0.5, dy: -diam * Math.sqrt(3) / 4},
                                {dx: diam * 0.5, dy: diam * Math.sqrt(3) / 4},
                                {dx: 0, dy: diam * Math.sqrt(3) / 2},
                                {dx: -diam * 0.5, dy: diam * Math.sqrt(3) / 4},
                                {dx: -diam * 0.5, dy: -diam * Math.sqrt(3) / 4}
                            ];

                            for (let j = 0; j < hexOffsets.length; j++) {
                                let potentialX = dots[i].x + hexOffsets[j].dx;
                                let potentialY = dots[i].y + hexOffsets[j].dy;

                                let {x: gridX, y: gridY} = getNearestHexPosition(potentialX, potentialY);

                                if (gridX > rad && gridX < W - rad && gridY > rad && gridY < H - rad) {
                                    let isOccupied = false;
                                    for (let k = 0; k < dots.length; k++) {
                                        if (Math.hypot(gridX - dots[k].x, gridY - dots[k].y) < diam * 0.9) {
                                            isOccupied = true;
                                            break;
                                        }
                                    }
                                    if (!isOccupied) {
                                        let distFromPlayer = Math.hypot(player.x - gridX, player.y - gridY);
                                        if (distFromPlayer < minDistance) {
                                            minDistance = distFromPlayer;
                                            bestPosition = { x: gridX, y: gridY };
                                        }
                                    }
                                }
                            }

                            if (bestPosition === null) {
                                bestPosition = getNearestHexPosition(player.x, player.y);
                            }

                            player.x = bestPosition.x;
                            player.y = bestPosition.y;

                            dots.push(new Dot(player.x, player.y, rad, player.mq, false));
                            player.y = -H/2;

                            same = [];
                            dots[dots.length - 1].boom = true;
                            same.push(dots[dots.length - 1]);

                            checkColor();

                            let cpt = same.length;

                            if (cpt >= 5) {
                                handleBoomEffect(cpt, same[0].mq);
                                noBoomStreak = 0;
                            } else {
                                for(let j = 0; j < same.length; j++){
                                    same[j].boom = false;
                                }
                                if(checkBoxAudio) createjs.Sound.play('soundball');
                                lastPoppedImageMq = -1;
                                consecutivePops = 0;
                                noBoomStreak++;
                                if (!slidingInProgress) {
                                    handleNoBoomEffect();
                                }
                            }

                            handleNextPlayerAndRow();
                            break;
                        }
                    }
                }

                player.x = player.x + 10 * Math.cos(player.t);
                player.y = player.y + 10 * Math.sin(player.t);
            }
        };

        const handleNoBoomEffect = () => {
            if (noBoomStreak >= NO_BOOM_THRESHOLD && !slidingInProgress) {
                slidingInProgress = true;
                const slideAmount = SLIDE_AMOUNT_PER_ROW;

                dots.forEach(dot => {
                    dot.nextY += slideAmount;
                });

                noBoomStreak = 0;

                setTimeout(() => {
                    slidingInProgress = false;
                }, SLIDE_AMOUNT_PER_ROW / SLIDE_INCREMENT_PER_FRAME * 16.666);
            }
        };


        const handleBoomEffect = (cpt, poppedMq) => {
            if (lastPoppedImageMq === -1 || lastPoppedImageMq !== poppedMq) {
                lastPoppedImageMq = poppedMq;
                consecutivePops = 1;
            } else if (lastPoppedImageMq === poppedMq) {
                consecutivePops++;
            }

            for(let b = same.length - 1; b >= 0; b--){
                let dotToBoom = same[b];
                for(let k = dots.length - 1; k >= 0; k--){
                    if(dots[k] === dotToBoom){
                        for(let n = 0; n < 10; n++){
                            booms.push(new Boom(dots[k].x, dots[k].y, dots[k].rad / 2, dots[k].mq));
                        }
                        dots.splice(k, 1);
                        countPoints++;
                        break;
                    }
                }
            }
            const infoElement = document.getElementById("info");
            if (infoElement) {
                infoElement.innerText = countPoints;
                infoElement.style.color = '#29F000';
                infoElement.style.fontSize = '2em';
            }

            setTimeout(() => {
                if (infoElement) {
                    infoElement.style.color = 'white';
                    infoElement.style.fontSize = '1.5em';
                }
            }, 20);

            checkDotsIsolate();

            if(cpt > 6){
                effetBigBoom = true;
                countPoints += 10;
                if (infoElement) infoElement.innerText = countPoints;
                setTimeout(() => {
                    effetBigBoom = false;
                    progress = 0;
                }, 1000);
                if(checkBoxAudio) createjs.Sound.play('soundbigboom');
            } else {
                if(checkBoxAudio && !effetBigBoom) createjs.Sound.play('soundboom');
            }
        };

        const handleNextPlayerAndRow = () => {
            newPlayer();
            nbrPlayer++;

            let maxDotY = 0;
            if (dots.length > 0) {
                maxDotY = Math.max(...dots.map(dot => dot.y + dot.rad));
            }

            const threshold = diam * 1.5;
            if (maxDotY >= lineEndY - threshold) {
                dots.forEach(dot => {
                    dot.nextY += diam * Math.sqrt(3) / 2;
                });
                setTimeout(() => {
                    newRow();
                }, 15);
            }
        };

        let nextRowOffset = 0;
        const newRow = () => {
            let currentYForNewRow = rad;
            if (dots.length > 0) {
                currentYForNewRow = Math.min(...dots.map(dot => dot.y)) - diam * Math.sqrt(3) / 2;
            }

            let estimatedRowNumber = Math.round((currentYForNewRow - rad) / (diam * Math.sqrt(3) / 2));
            nextRowOffset = (estimatedRowNumber % 2 === 0) ? 0 : rad;

            let startX = rad + nextRowOffset;

            for(let x = startX; x < W - rad; x += diam){
                let nC = ~~random(gameImages.length);
                if (x > rad - diam && x < W + diam) {
                    dots.push(new Dot(x, currentYForNewRow, rad, nC));
                }
            }
        };

        const drawLineShoot = () => {
            if(move && !player.run && !player.play) {
                ctx.beginPath();
                ctx.strokeStyle = 'rgba(255,255,255,0.8)';
                ctx.lineWidth = 1;
                ctx.moveTo(player.x, player.y);
                ctx.lineTo(mouse.x, mouse.y);
                ctx.stroke();
                ctx.closePath();
            }
        };

        const drawLineEnd = () =>{
            ctx.beginPath();
            ctx.strokeStyle = 'rgba(255,255,255,0.8)';
            ctx.lineWidth = 2;
            ctx.moveTo(0,lineEndY);
            ctx.lineTo(W, lineEndY);
            ctx.stroke();
            ctx.closePath();
        };

        const blastRings = (x, y, radius, lw, color) => {
            if(radius < 0) radius = 0;
            ctx.beginPath();
            ctx.lineWidth = lw;
            ctx.strokeStyle = color;
            ctx.arc(x, y, radius + 30, 0, Math.PI * 2, false);
            ctx.stroke();
        };

        const blastParticle = (x, y, sizeFont, a) => {
            let currentX = x + progress/2 * Math.cos(a);
            let currentY = y + progress/2 * Math.sin(a);

            ctx.beginPath();
            ctx.font = sizeFont + "px Arial";
            ctx.fillStyle = 'white';
            ctx.fillText('🔴', currentX, currentY);
        };

        const createEffet = () => {
            progress += 15;
            blastRings(W/2, H/2, progress, 10, "white");
            blastRings(W/2, H/2, progress - 30, 15, "yellow");
            blastRings(W/2, H/2, progress - 50, 20, "orange");
            blastRings(W/2, H/2, progress - 100, 30, "red");
            for(let i = 0; i < Math.PI * 2; i += Math.PI / 8){
                blastParticle(W/2, H/2, rad, i);
            }
        };

        const createBall = () => {
            rad = W / 16 - 0.01;
            diam = rad * 2;
            lineEndY = H - 1.7 * diam;

            dots = [];

            let currentY = rad;
            for (let r = 0; r < 6; r++) {
                let rowXOffset = (r % 2 === 0) ? 0 : rad;

                for (let c = 0; c < Math.floor((W - rowXOffset) / diam); c++) {
                    let x = rad + c * diam + rowXOffset;
                    let y = currentY;

                    if (x - rad > -diam && x + rad < W + diam) {
                        dots.push(new Dot(x, y, rad, ~~random(gameImages.length)));
                    }
                }
                currentY += diam * Math.sqrt(3) / 2;
            }
        };

        const newPlayer = () => {
            let playerMq = ~~random(gameImages.length);
            if (consecutivePops >= 2 && lastPoppedImageMq !== -1) {
                playerMq = lastPoppedImageMq;
                consecutivePops = 0;
                lastPoppedImageMq = -1;
            }
            player = new Player(W/2, H - rad * 2, rad, playerMq);
        };

        const animBooms = () => {
            for(let i = booms.length - 1; i >= 0; i--){
                booms[i].update();
                if(booms[i].rad <= 0.6) booms.splice(i, 1);
            }
        };

        const checkDotsIsolate = () => {
            const collisionThreshold = diam * 1.0;

            dots.forEach(dot => {
                dot.isolate = false;
            });

            let connected = new Set();
            let q = [];

            for (let i = 0; i < dots.length; i++) {
                if (!dots[i].boom && dots[i].y <= rad * 1.1) {
                    q.push(dots[i]);
                    connected.add(dots[i]);
                }
            }

            let head = 0;
            while (head < q.length) {
                let current = q[head++];

                for (let i = 0; i < dots.length; i++) {
                    let neighbor = dots[i];
                    if (current !== neighbor && !connected.has(neighbor) && !neighbor.boom) {

                        let d = Math.hypot(current.x - neighbor.x, current.y - neighbor.y);
                        if (d < collisionThreshold) {
                            q.push(neighbor);
                            connected.add(neighbor);
                        }
                    }
                }
            }

            let fallCount = 0;
            for (let i = 0; i < dots.length; i++) {
                if (!connected.has(dots[i]) && !dots[i].boom) {
                    dots[i].isolate = true;
                    dots[i].nextY = H + rad;
                    dots[i].speed = 7;
                    fallCount++;
                }
            }
            countPoints += fallCount;
            const infoElement = document.getElementById("info");
            if (infoElement) infoElement.innerText = countPoints;
        };

        const checkEndGame = () => {
            for(let i = 0; i <dots.length; i++){
                if((dots[i].y + rad >= lineEndY && !dots[i].isolate)) {
                    gamePlay = false;
                    endGame();
                    break;
                }
                if(dots[i].y > H + rad && dots[i].isolate){
                    dots.splice(i, 1);
                    i--;
                }
            }
        };

        const endGame = () => {
            if(checkBoxAudio) createjs.Sound.play('soundend');
            const endgameElement = document.getElementById("endgame");
            const scoreElement = document.getElementById("score");
            const highScoreDisplayElement = document.getElementById("highScoreDisplay");

            if (endgameElement) endgameElement.style.display =  "flex";
            if (scoreElement) scoreElement.innerText = "Score: " + countPoints;

            let highScore = localStorage.getItem('bubbleHighScore');
            if (highScore === null || isNaN(highScore)) {
                highScore = 0;
            } else {
                highScore = parseInt(highScore);
            }

            if (countPoints > highScore) {
                highScore = countPoints;
                localStorage.setItem('bubbleHighScore', highScore);
                if (highScoreDisplayElement) {
                    highScoreDisplayElement.innerText = "New High Score: " + highScore;
                    highScoreDisplayElement.style.display = 'block';
                    highScoreDisplayElement.style.color = '#F4E104';
                }
            } else {
                if (highScoreDisplayElement) {
                    highScoreDisplayElement.innerText = "High Score: " + highScore;
                    highScoreDisplayElement.style.display = 'block';
                    highScoreDisplayElement.style.color = 'white';
                }
            }

            setTimeout(()=>{
                if (endgameElement) endgameElement.style.display =  "none";
                if (highScoreDisplayElement) highScoreDisplayElement.style.display = 'none';
                newGame();
                gamePlay = true;
            },3000);
        };

        const newGame = () => {
            dots = [];
            booms = [];
            same = [];
            nbrPlayer = 0;
            countPoints = 0;
            progress = 0;
            effetBigBoom = false;
            lastPoppedImageMq = -1;
            consecutivePops = 0;
            noBoomStreak = 0;
            slidingInProgress = false;

            const infoElement = document.getElementById("info");
            if (infoElement) infoElement.innerText = countPoints;

            initWidthHeight();
            createBall();
            newPlayer();
        };

        const animate = () => {
            if(gamePlay){
                ctx.clearRect(0,0,W,H);
                calcFPS();
                drawLineEnd();
                dots.map(x=>x.update());
                checkPlayer();
                player.update();
                drawLineShoot();
                animBooms();
                if(effetBigBoom) createEffet();
            }
            requestAnimationFrame(animate);
        };

        const loadAudio = () => {
            createjs.Sound.registerSound(srcSoundSelect, 'soundball');
            createjs.Sound.registerSound(srcSoundBoom, 'soundboom');
            createjs.Sound.registerSound(srcSoundEnd, 'soundend');
            createjs.Sound.registerSound(srcSoundBigBoom, 'soundbigboom');

            createjs.Sound.volume = 0.5;
        };

        const initWidthHeight = () => {
            const containerElement = document.getElementById("gameContainer");
            c.width = W = innerWidth;
            c.height = H = innerHeight;

            if(innerWidth > innerHeight){
                c.width = W = innerHeight * 0.6;
                if (containerElement) containerElement.style.width = W + "px";
                containerElement.style.height = "100%";
            } else {
                if (containerElement) {
                    containerElement.style.width = "100%";
                    containerElement.style.height = "100%";
                }
            }

            rad = W / 16 - 0.01;
            diam = rad * 2;
            lineEndY = H - 1.7 * diam;

            if (dots.length > 0) {
                const oldRad = dots[0].rad;
                const scaleFactor = rad / oldRad;

                dots.forEach(dot => {
                    dot.x *= scaleFactor;
                    dot.y *= scaleFactor;
                    dot.rad = rad;
                    dot.nextY *= scaleFactor;
                });
                player.x = W / 2;
                player.y = H - rad * 2;
                player.rad = rad;
            } else {
                createBall();
                newPlayer();
            }
        };

        const initGameAssets = () => {
            c = document.getElementById("canvas");
            ctx = c.getContext("2d");

            const storedImages = localStorage.getItem('gameImages');
            if (storedImages) {
                const imageBase64s = JSON.parse(storedImages);
                let loadedCount = 0;
                const totalImages = imageBase64s.length;

                const isValid = totalImages === 4 && imageBase64s.every(img => typeof img === 'string' && img.startsWith('data:image'));

                if (!isValid) {
                    alert("Please upload 4 valid photos to start the game. You are being redirected to the image selection page.");
                    // selectionScreen'ı tekrar göster ve gameContainer'ı gizle
                    selectionScreen.style.display = 'flex';
                    gameContainer.style.display = 'none';
                    // localStorage'ı temizle
                    localStorage.removeItem('gameImages');
                    return;
                }

                imageBase64s.forEach((base64, index) => {
                    const img = new Image();
                    img.onload = () => {
                        loadedCount++;
                        if (loadedCount === totalImages) {
                            initWidthHeight();
                            loadAudio();
                            eventsListener();
                            requestAnimationFrame(animate);
                        }
                    };
                    img.onerror = () => {
                        console.error(`Image could not be loaded: index ${index}. Falling back to default.`);
                        loadedCount++;
                        gameImages[index] = new Image();
                        if (loadedCount === totalImages) {
                            initWidthHeight();
                            loadAudio();
                            eventsListener();
                            requestAnimationFrame(animate);
                        }
                    };
                    img.src = base64;
                    gameImages.push(img);
                });
            } else {
                alert("Please upload 4 photos to start the game. You are being redirected to the image selection page.");
                selectionScreen.style.display = 'flex';
                gameContainer.style.display = 'none';
                return;
            }
        };

        // Sayfa yüklendiğinde başlangıç ekranını göster
        document.addEventListener('DOMContentLoaded', () => {
            selectionScreen.style.display = 'flex';
            gameContainer.style.display = 'none';
            checkAllImagesLoaded(); // Başlangıçta buton durumunu kontrol et
        });
    </script>
</body>
</html>

''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
