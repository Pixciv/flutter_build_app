let c, ctx, W, H;
let gamePlay = true;
let dots = [], booms = [], same = [];
let rad, diam;
let gameImages = [];
let player, nbrPlayer = 0;
let mouse, touch;
let lastTimeCalled;
let countPoints = 0, lineEndY = 0, nbrBallsLevel = 4, progress = 0;
// MODIFIED: Ses varsayılan olarak açık olsun
let checkBoxAudio = true, effetBigBoom = false, move = false;

const srcSoundSelect = "https://lolofra.github.io/balls/audio/selected.mp3";
const srcSoundBoom = "https://lolofra.github.io/balls/audio/sbomb.mp3";
const srcSoundEnd = "https://lolofra.github.io/balls/audio/end.mp3";
const srcSoundBigBoom = "https://lolofra.github.io/balls/audio/bigBoom.mp3";

let lastPoppedImageMq = -1;
let consecutivePops = 0;

// NEW: No boom streak counter and sliding control
let noBoomStreak = 0;
const NO_BOOM_THRESHOLD = 2; // How many shots without a boom before balls slide down
const SLIDE_AMOUNT_PER_ROW = diam * Math.sqrt(3) / 2; // Height of one full hexagonal row
const SLIDE_INCREMENT_PER_FRAME = 2; // Pixels per frame for smooth slide animation
let slidingInProgress = false; // To prevent multiple slides at once

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
        this.nextY = y; // Target Y position for smooth sliding/falling
        this.isolate = false; // Whether the ball is isolated and should fall
        this.speed = 0.7; // Fall speed for isolated balls
        this.borderColor = getFrameColor(this.mq);
    }
    fall() {
        if(this.isolate) {
             this.y += this.speed; // Increase fall speed if isolated
        } else if (this.y < this.nextY) { // Smooth slide down if target Y is lower
            this.y = Math.min(this.nextY, this.y + SLIDE_INCREMENT_PER_FRAME); // Animate towards nextY
        } else if (this.y > this.nextY) { // Also allow slight upward correction if it overshoots
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
        // MODIFIED: Kuyruğun uzunluğu artırıldı
        this.trail = []; // Kuyruklu yıldız efekti için geçmiş pozisyonları saklayacak dizi
        this.trailMaxLength = 20; // Kuyruğun uzunluğu (kaç nokta saklanacak)
    }
    update() {
        // Kuyruklu yıldız efekti için geçmiş pozisyonları kaydetme ve çizme
        if (this.run) { // Sadece top hareket halindeyken iz bırak
            this.trail.push({x: this.x, y: this.y, rad: this.rad}); // Mevcut pozisyonu ekle
            if (this.trail.length > this.trailMaxLength) {
                this.trail.shift(); // En eski pozisyonu sil
            }
        } else {
            this.trail = []; // Top durduğunda veya yeni atışa hazırlanırken izi temizle
        }

        // İzdeki her noktayı çiz
        for (let i = 0; i < this.trail.length; i++) {
            const trailDot = this.trail[i];
            // MODIFIED: Şeffaflık ve boyut küçülme hesaplaması iyileştirildi
            const ratio = i / this.trail.length;
            const alpha = ratio * 0.7; // Kuyruk sonunda daha şeffaf (max alpha 0.7)
            const sizeReduction = (1 - ratio) * 0.7; // Kuyruk sonunda daha küçük (max küçülme 0.7)

            ctx.beginPath();
            ctx.arc(trailDot.x, trailDot.y, trailDot.rad * (1 - sizeReduction), 0, 2 * Math.PI);
            ctx.fillStyle = `rgba(255, 255, 255, ${alpha})`; // Beyaz ve şeffaflaşan bir renk
            ctx.fill();
            ctx.closePath();
        }

        // Mevcut topun çizimi (mevcut kodunuz)
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
        // MODIFIED: Buton başlangıçta ses açık iconunu göstersin
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
        let newlyAddedDot = dots[dots.length - 1]; // The most recently added dot (player's shot)

        if (!visited.has(newlyAddedDot)) {
            queue.push(newlyAddedDot);
            visited.add(newlyAddedDot);
            newlyAddedDot.boom = true; // Mark for potential boom
        }
    }

    let head = 0;
    while (head < queue.length) {
        let currentDot = queue[head++];

        for (let i = 0; i < dots.length; i++) {
            let neighborDot = dots[i];

            if (currentDot !== neighborDot &&
                currentDot.mq === neighborDot.mq && // Same image/type
                !visited.has(neighborDot)) {

                let d0 = Math.hypot(currentDot.x - neighborDot.x, currentDot.y - neighborDot.y);
                if (d0 < (currentDot.rad + neighborDot.rad) * 1.05) { // Slightly increased threshold for connectivity
                    queue.push(neighborDot);
                    visited.add(neighborDot);
                    neighborDot.boom = true; // Mark for potential boom
                }
            }
        }
    }
    same = Array.from(visited); // All connected dots of the same type
};

// This function accurately calculates the nearest hexagonal grid position
const getNearestHexPosition = (x, y) => {
    const rowHeight = diam * Math.sqrt(3) / 2;
    const colWidth = diam;

    // Calculate approximate row and column
    let approxRow = (y - rad) / rowHeight;
    let targetRow = Math.round(approxRow);

    // Determine row offset for staggered columns
    let rowOffset = (targetRow % 2 === 0) ? 0 : rad;

    let approxCol = (x - rad - rowOffset) / colWidth;
    let targetCol = Math.round(approxCol);

    // Calculate precise x and y for the center of the hexagonal cell
    let nearestX = rad + targetCol * colWidth + rowOffset;
    let nearestY = rad + targetRow * rowHeight;

    return { x: nearestX, y: nearestY };
};

const checkPlayer = () => {
    checkEndGame();
    if(player.run){
        let hitOccurred = false;

        // Ceiling collision check
        if (player.y <= rad) {
            player.run = false;
            hitOccurred = true;

            let {x: newDotX, y: newDotY} = getNearestHexPosition(player.x, rad);

            dots.push(new Dot(newDotX, newDotY, rad, player.mq, false));
            player.y = -H/2; // Move player off screen

            same = [];
            dots[dots.length - 1].boom = true; // Mark the newly added dot for color checking
            same.push(dots[dots.length - 1]);

            checkColor(); // Find all connected dots of the same type

            let cpt = same.length;

            // MODIFIED: Explosion threshold set to 5
            if (cpt >= 5) { // If 5 or more connected, they pop
                handleBoomEffect(cpt, same[0].mq);
                noBoomStreak = 0; // Reset streak on boom
            } else { // No boom
                for(let i = 0; i < same.length; i++){
                    same[i].boom = false; // Unmark if no boom
                }
                if(checkBoxAudio) createjs.Sound.play('soundball');
                lastPoppedImageMq = -1; // Reset consecutive pop tracking
                consecutivePops = 0;
                noBoomStreak++; // Increment streak if no boom
                if (!slidingInProgress) { // Only trigger slide if not already sliding
                    handleNoBoomEffect();
                }
            }

            handleNextPlayerAndRow(); // Prepare next player and check for new row
        }

        // --- WALL COLLISION CHECK AND REDIRECTION ---
        // Left wall collision
        if (player.x - player.rad < 0) {
            player.x = player.rad;
            player.t = Math.PI - player.t; // Reverse horizontal direction
        }
        // Right wall collision
        else if (player.x + player.rad > W) {
            player.x = W - player.rad;
            player.t = Math.PI - player.t; // Reverse horizontal direction
        }
        // Bottom wall collision (below player's starting line - this should ideally not happen if aiming up)
        // Kept for robustness, but usually player aims upwards.
        else if (player.y + player.rad > H - rad * 2) {
            player.y = H - rad * 2 - player.rad;
            player.t = 2 * Math.PI - player.t; // Reverse vertical direction
        }


        if (!hitOccurred) {
            for(let i = 0; i < dots.length; i++){
                if (dots[i].boom) continue; // Skip dots already marked for boom

                let d0 = Math.hypot(player.x - dots[i].x, player.y - dots[i].y );

                const collisionThreshold = (player.rad + dots[i].rad) * 0.95; // Collision detection threshold

                if(d0 < collisionThreshold) {
                    player.run = false;
                    hitOccurred = true;

                    // Find the best available hexagonal position around the hit dot
                    let bestPosition = null;
                    let minDistance = Infinity;

                    // Offsets for 6 surrounding hexagonal neighbors
                    const hexOffsets = [
                        {dx: 0, dy: -diam * Math.sqrt(3) / 2}, // Up
                        {dx: diam * 0.5, dy: -diam * Math.sqrt(3) / 4}, // Up-Right
                        {dx: diam * 0.5, dy: diam * Math.sqrt(3) / 4}, // Down-Right
                        {dx: 0, dy: diam * Math.sqrt(3) / 2}, // Down
                        {dx: -diam * 0.5, dy: diam * Math.sqrt(3) / 4}, // Down-Left
                        {dx: -diam * 0.5, dy: -diam * Math.sqrt(3) / 4}  // Up-Left
                    ];

                    for (let j = 0; j < hexOffsets.length; j++) {
                        let potentialX = dots[i].x + hexOffsets[j].dx;
                        let potentialY = dots[i].y + hexOffsets[j].dy;

                        // Get the exact grid position for this potential spot
                        let {x: gridX, y: gridY} = getNearestHexPosition(potentialX, potentialY);

                        // Ensure position is within canvas bounds
                        if (gridX > rad && gridX < W - rad && gridY > rad && gridY < H - rad) {
                            let isOccupied = false;
                            for (let k = 0; k < dots.length; k++) {
                                // Check if this grid position is already occupied by another ball
                                if (Math.hypot(gridX - dots[k].x, gridY - dots[k].y) < diam * 0.9) {
                                    isOccupied = true;
                                    break;
                                }
                            }
                            if (!isOccupied) {
                                // If not occupied, evaluate distance from player's actual collision point
                                let distFromPlayer = Math.hypot(player.x - gridX, player.y - gridY);
                                if (distFromPlayer < minDistance) {
                                    minDistance = distFromPlayer;
                                    bestPosition = { x: gridX, y: gridY };
                                }
                            }
                        }
                    }

                    // Fallback if no ideal hexagonal position is found (shouldn't happen often)
                    if (bestPosition === null) {
                        bestPosition = getNearestHexPosition(player.x, player.y);
                    }

                    // Place the player's ball at the determined best position
                    player.x = bestPosition.x;
                    player.y = bestPosition.y;

                    dots.push(new Dot(player.x, player.y, rad, player.mq, false));
                    player.y = -H/2; // Move player off screen

                    same = [];
                    dots[dots.length - 1].boom = true;
                    same.push(dots[dots.length - 1]);

                    checkColor(); // Find connected same-colored balls

                    let cpt = same.length;

                    // MODIFIED: Explosion threshold set to 5
                    if (cpt >= 5) {
                        handleBoomEffect(cpt, same[0].mq);
                        noBoomStreak = 0; // Reset streak on boom
                    } else {
                        for(let j = 0; j < same.length; j++){
                            same[j].boom = false;
                        }
                        if(checkBoxAudio) createjs.Sound.play('soundball');
                        lastPoppedImageMq = -1;
                        consecutivePops = 0;
                        noBoomStreak++; // Increment streak if no boom
                        if (!slidingInProgress) {
                            handleNoBoomEffect();
                        }
                    }

                    handleNextPlayerAndRow();
                    break; // Exit loop after collision
                }
            }
        }

        // Continue moving player ball if no collision
        player.x = player.x + 10 * Math.cos(player.t);
        player.y = player.y + 10 * Math.sin(player.t);
    }
};

// Function to handle balls sliding down if no boom occurs
const handleNoBoomEffect = () => {
    if (noBoomStreak >= NO_BOOM_THRESHOLD && !slidingInProgress) {
        slidingInProgress = true;
        const slideAmount = SLIDE_AMOUNT_PER_ROW; // Slide by one full row height for perfect alignment

        // Update target Y for all balls
        dots.forEach(dot => {
            dot.nextY += slideAmount;
        });

        // Reset streak after initiating slide
        noBoomStreak = 0;

        // Reset slidingInProgress after a delay to allow next slide
        // This delay should be roughly the time it takes for the slide animation to finish
        setTimeout(() => {
            slidingInProgress = false;
        }, SLIDE_AMOUNT_PER_ROW / SLIDE_INCREMENT_PER_FRAME * 16.666); // Approximate time for slide animation (16.666ms per frame at 60fps)
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
                for(let n = 0; n < 10; n++){ // Create boom particles
                    booms.push(new Boom(dots[k].x, dots[k].y, dots[k].rad / 2, dots[k].mq));
                }
                dots.splice(k, 1); // Remove the popped dot
                countPoints++;
                break;
            }
        }
    }
    const infoElement = document.getElementById("info");
    if (infoElement) {
        infoElement.innerText = countPoints;
        infoElement.style.color = '#29F000'; // Green for score change
        infoElement.style.fontSize = '2em';
    }

    setTimeout(() => {
        if (infoElement) {
            infoElement.style.color = 'white'; // Revert color
            infoElement.style.fontSize = '1.5em'; // Revert size
        }
    }, 20); // Brief visual feedback for score increase

    checkDotsIsolate(); // Check for isolated balls after a pop

    if(cpt > 6){ // Big boom effect for large pops (more than 6 in this case)
        effetBigBoom = true;
        countPoints += 10; // Bonus points for big boom
        if (infoElement) infoElement.innerText = countPoints;
        setTimeout(() => {
            effetBigBoom = false;
            progress = 0; // Reset progress for big boom animation
        }, 1000);
        if(checkBoxAudio) createjs.Sound.play('soundbigboom');
    } else {
        if(checkBoxAudio && !effetBigBoom) createjs.Sound.play('soundboom');
    }
};

const handleNextPlayerAndRow = () => {
    newPlayer(); // Get next player ball
    nbrPlayer++;

    let maxDotY = 0;
    if (dots.length > 0) {
        maxDotY = Math.max(...dots.map(dot => dot.y + dot.rad));
    }

    // Check if balls are getting too low, add a new row from top
    const threshold = diam * 1.5; // Threshold for adding a new row
    if (maxDotY >= lineEndY - threshold) {
        // Shift all existing dots down by one row height to make space for the new row
        dots.forEach(dot => {
            dot.nextY += diam * Math.sqrt(3) / 2;
        });
        // Add new row after a short delay for smooth transition
        setTimeout(() => {
            newRow();
        }, 15);
    }
};

let nextRowOffset = 0;
const newRow = () => {
    // This function adds a new row at the very top of the grid.
    let currentYForNewRow = rad; // Default for first row
    if (dots.length > 0) {
        // Find the Y of the highest existing ball to determine where the new row starts
        // Subtract one row height to place it just above the highest existing row
        currentYForNewRow = Math.min(...dots.map(dot => dot.y)) - diam * Math.sqrt(3) / 2;
    }

    let estimatedRowNumber = Math.round((currentYForNewRow - rad) / (diam * Math.sqrt(3) / 2));
    nextRowOffset = (estimatedRowNumber % 2 === 0) ? 0 : rad;

    let startX = rad + nextRowOffset;

    for(let x = startX; x < W - rad; x += diam){
        let nC = ~~random(gameImages.length);
        if (x > rad - diam && x < W + diam) { // Ensure balls are within horizontal bounds
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
    ctx.fillText('🔴', currentX, currentY); // Using an emoji for particle
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
    rad = W / 16 - 0.01; // Radius based on canvas width
    diam = rad * 2; // Diameter
    lineEndY = H - 1.7 * diam; // Game over line position

    dots = []; // Clear existing balls

    let currentY = rad; // Starting Y for the first row
    for (let r = 0; r < 6; r++) { // Create initial 6 rows of balls
        let rowXOffset = (r % 2 === 0) ? 0 : rad; // Staggered rows

        for (let c = 0; c < Math.floor((W - rowXOffset) / diam); c++) {
            let x = rad + c * diam + rowXOffset;
            let y = currentY;

            // Ensure balls are within horizontal bounds. Remove redundant checks if getNearestHexPosition handles it.
            if (x - rad > -diam && x + rad < W + diam) { // Allow slight overflow for visual completeness
                 dots.push(new Dot(x, y, rad, ~~random(gameImages.length)));
            }
        }
        currentY += diam * Math.sqrt(3) / 2; // Move to next row's Y position
    }
};

const newPlayer = () => {
    let playerMq = ~~random(gameImages.length); // Random image for player ball
    // If consecutive pops of the same image, give player that image
    if (consecutivePops >= 2 && lastPoppedImageMq !== -1) {
        playerMq = lastPoppedImageMq;
        consecutivePops = 0;
        lastPoppedImageMq = -1;
    }
    player = new Player(W/2, H - rad * 2, rad, playerMq); // Player ball at bottom center
};

const animBooms = () => {
    for(let i = booms.length - 1; i >= 0; i--){
        booms[i].update();
        if(booms[i].rad <= 0.6) booms.splice(i, 1); // Remove small boom particles
    }
};

const checkDotsIsolate = () => {
    const collisionThreshold = diam * 1.0; // Proximity to consider balls connected

    dots.forEach(dot => {
        dot.isolate = false; // Reset isolation status
    });

    let connected = new Set(); // To track balls connected to the top
    let q = []; // Queue for Breadth-First Search (BFS)

    // Start BFS from balls at the very top (within a small margin)
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
            // If a ball is not connected to the top and not already booming, it's isolated
            dots[i].isolate = true;
            dots[i].nextY = H + rad; // Set target to fall off screen
            dots[i].speed = 7; // Faster fall speed
            fallCount++;
        }
    }
    countPoints += fallCount; // Add points for falling balls
    const infoElement = document.getElementById("info");
    if (infoElement) infoElement.innerText = countPoints;
};

const checkEndGame = () => {
    for(let i = 0; i <dots.length; i++){
        // Game ends if any non-isolated ball reaches or crosses the end line
        // We also check for isolated balls that might cross the line before falling off completely
        if((dots[i].y + rad >= lineEndY && !dots[i].isolate)) {
            gamePlay = false;
            endGame();
            break;
        }
        // Remove isolated balls once they are completely off screen
        if(dots[i].y > H + rad && dots[i].isolate){
            dots.splice(i, 1);
            i--; // Decrement i because we removed an element
        }
    }
};

const endGame = () => {
    if(checkBoxAudio) createjs.Sound.play('soundend');
    const endgameElement = document.getElementById("endgame");
    const scoreElement = document.getElementById("score");
    const highScoreDisplayElement = document.getElementById("highScoreDisplay");

    if (endgameElement) endgameElement.style.display =  "flex"; // Show game over screen
    // MODIFIED: İngilizce skor metni
    if (scoreElement) scoreElement.innerText = "Score: " + countPoints; // Display current score

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
            // MODIFIED: İngilizce yüksek skor metni
            highScoreDisplayElement.innerText = "New High Score: " + highScore; // Display new high score
            highScoreDisplayElement.style.display = 'block';
            highScoreDisplayElement.style.color = '#F4E104'; // Yellow color for new high score
        }
    } else {
        if (highScoreDisplayElement) {
            // MODIFIED: İngilizce yüksek skor metni
            highScoreDisplayElement.innerText = "High Score: " + highScore; // Display existing high score
            highScoreDisplayElement.style.display = 'block';
            highScoreDisplayElement.style.color = 'white';
        }
    }

    setTimeout(()=>{
        if (endgameElement) endgameElement.style.display =  "none"; // Hide game over screen
        if (highScoreDisplayElement) highScoreDisplayElement.style.display = 'none';
        newGame(); // Start a new game
        gamePlay = true; // Set game back to playing state
    },3000); // Display for 3 seconds
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
    noBoomStreak = 0; // Reset no boom streak for new game
    slidingInProgress = false; // Reset sliding status for new game

    const infoElement = document.getElementById("info");
    if (infoElement) infoElement.innerText = countPoints; // Reset score display

    initWidthHeight(); // Re-initialize dimensions and ball creation
    createBall(); // Create initial balls
    newPlayer(); // Create initial player ball
};

const animate = () => {
    if(gamePlay){
        ctx.clearRect(0,0,W,H); // Clear canvas
        calcFPS(); // Calculate and display FPS
        drawLineEnd(); // Draw game end line
        dots.map(x=>x.update()); // Update and draw all balls
        // drawLineShoot(); // Aiming line is now drawn by player.update if mouse is active
        checkPlayer(); // Check player ball's movement and collisions
        player.update(); // Update and draw player ball (and its trail)
        // Redraw aiming line AFTER player update so it's on top of other elements but doesn't interfere with player's trail
        drawLineShoot(); // Draw aiming line here so it's always visible above the player ball
        animBooms(); // Animate boom particles
        if(effetBigBoom) createEffet(); // Animate big boom effect
    }
    requestAnimationFrame(animate); // Loop animation
};

const loadAudio = () => {
    createjs.Sound.registerSound(srcSoundSelect, 'soundball');
    createjs.Sound.registerSound(srcSoundBoom, 'soundboom');
    createjs.Sound.registerSound(srcSoundEnd, 'soundend');
    createjs.Sound.registerSound(srcSoundBigBoom, 'soundbigboom');

    createjs.Sound.volume = 0.5; // Set audio volume
};

const initWidthHeight = () => {
    const containerElement = document.getElementById("container");
    c.width = W = innerWidth;
    c.height = H = innerHeight;

    // Adjust canvas size for portrait orientation on mobile, keep aspect ratio
    if(innerWidth > innerHeight){
        c.width = W = innerHeight * 0.6; // Limit width to 60% of height for landscape view
        if (containerElement) containerElement.style.width = W + "px";
        containerElement.style.height = "100%";
    } else {
        if (containerElement) {
            containerElement.style.width = "100%"; // Full width for portrait
            containerElement.style.height = "100%";
        }
    }

    rad = W / 16 - 0.01; // Recalculate radius based on new width
    diam = rad * 2;
    lineEndY = H - 1.7 * diam; // Recalculate game end line

    // Adjust positions of existing balls if canvas size changes
    if (dots.length > 0) {
        const oldRad = dots[0].rad;
        const scaleFactor = rad / oldRad;

        dots.forEach(dot => {
            dot.x *= scaleFactor;
            dot.y *= scaleFactor;
            dot.rad = rad;
            dot.nextY *= scaleFactor; // Scale target Y as well
        });
        player.x = W / 2;
        player.y = H - rad * 2;
        player.rad = rad;
    } else {
        createBall(); // Create initial balls if none exist
        newPlayer(); // Create initial player ball
    }
};

const init = () => {
    c = document.getElementById("canvas");
    ctx = c.getContext("2d");

    const storedImages = localStorage.getItem('gameImages');
    if (storedImages) {
        const imageBase64s = JSON.parse(storedImages);
        let loadedCount = 0;
        const totalImages = imageBase64s.length;

        const isValid = totalImages === 4 && imageBase64s.every(img => typeof img === 'string' && img.startsWith('data:image'));

        if (!isValid) {
            // MODIFIED: İngilizce uyarı mesajı
            alert("Please upload 4 valid photos to start the game. You are being redirected to the image selection page.");
            window.location.href = 'indexpic.html';
            return;
        }

        imageBase64s.forEach((base64, index) => {
            const img = new Image();
            img.onload = () => {
                loadedCount++;
                if (loadedCount === totalImages) {
                    initGameAssets(); // Start game assets after all images loaded
                }
            };
            img.onerror = () => {
                console.error(`Image could not be loaded: index ${index}. Falling back to default.`);
                loadedCount++;
                gameImages[index] = new Image(); // Fallback to a blank image or placeholder
                if (loadedCount === totalImages) {
                    initGameAssets();
                }
            };
            img.src = base64;
            gameImages.push(img);
        });
    } else {
        // MODIFIED: İngilizce uyarı mesajı
        alert("Please upload 4 photos to start the game. You are being redirected to the image selection page.");
        window.location.href = 'indexpic.html';
        return;
    }
};

const initGameAssets = () => {
    initWidthHeight(); // Initialize dimensions and objects
    loadAudio(); // Load sounds
    eventsListener(); // Set up event listeners
    requestAnimationFrame(animate); // Start the game loop
}

window.onload = init; // Initialize on window load
