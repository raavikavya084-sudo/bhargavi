<!DOCTYPE html>
<html>
<head>
<title>Advanced Image Learning Agent</title>
<style>
body{
  background:#0f2027;
  font-family:Arial;
  color:white;
  text-align:center;
}
.container{
  background:#1b3a4b;
  width:420px;
  margin:50px auto;
  padding:25px;
  border-radius:15px;
  box-shadow:0 0 25px #00ffd5;
}
h1{color:#00ffd5;}
input,button{
  margin:8px;
  padding:10px;
  border-radius:6px;
  border:none;
}
button{
  background:#00ffd5;
  font-weight:bold;
  cursor:pointer;
}
button:hover{background:#00c9a7;}
img{
  max-width:120px;
  margin:10px;
  border:2px solid #00ffd5;
  border-radius:8px;
}
#result{margin-top:10px;font-size:18px;color:#ffeb3b;}
.memory{font-size:12px;color:#c8fff4;margin-top:10px;}
</style>
</head>

<body>

<div class="container">
<h1>Image Learning Agent</h1>

<p>Upload Image to Train Agent:</p>
<input type="file" id="trainImage" accept="image/*"><br>
<input type="text" id="label" placeholder="Enter Label (e.g. Bottle)">
<button onclick="learnImage()">Learn</button>

<hr>

<p>Upload Image to Predict:</p>
<input type="file" id="testImage" accept="image/*"><br>
<button onclick="predictImage()">Predict</button>

<div id="preview"></div>
<h3 id="result"></h3>

<div class="memory" id="memoryLog"></div>
</div>

<canvas id="canvas" width="50" height="50" style="display:none;"></canvas>

<script>
let memory = JSON.parse(localStorage.getItem("imageAgentMemory")) || [];

function imageToVector(img){
  const canvas = document.getElementById("canvas");
  const ctx = canvas.getContext("2d");
  ctx.drawImage(img,0,0,50,50);
  const data = ctx.getImageData(0,0,50,50).data;
  let vector=[];
  for(let i=0;i<data.length;i+=4){
    let avg = (data[i]+data[i+1]+data[i+2])/3;
    vector.push(avg);
  }
  return vector;
}

function learnImage(){
  const file = document.getElementById("trainImage").files[0];
  const label = document.getElementById("label").value;

  if(!file || !label){
    alert("Upload image and enter label");
    return;
  }

  const img = new Image();
  img.onload = ()=>{
    const vector = imageToVector(img);
    memory.push({label:label,vector:vector});
    localStorage.setItem("imageAgentMemory",JSON.stringify(memory));
    document.getElementById("result").innerText="Agent Learned Image Successfully 🧠";
    showMemory();
  };
  img.src = URL.createObjectURL(file);
}

function similarity(v1,v2){
  let sum=0;
  for(let i=0;i<v1.length;i++){
    sum += Math.abs(v1[i]-v2[i]);
  }
  return sum;
}

function predictImage(){
  const file = document.getElementById("testImage").files[0];
  if(!file){
    alert("Upload image to predict");
    return;
  }

  const img = new Image();
  img.onload = ()=>{
    const vector = imageToVector(img);

    let bestMatch=null;
    let minDist=Infinity;

    memory.forEach(m=>{
      const dist = similarity(vector,m.vector);
      if(dist < minDist){
        minDist = dist;
        bestMatch = m.label;
      }
    });

    document.getElementById("preview").innerHTML = `<img src="${img.src}">`;

    if(bestMatch){
      document.getElementById("result").innerText =
        "Agent Guess: " + bestMatch;
    }else{
      document.getElementById("result").innerText =
        "Agent doesn't know this image";
    }
  };
  img.src = URL.createObjectURL(file);
}

function showMemory(){
  let text="<b>Agent Memory:</b><br>";
  memory.slice(-5).forEach(m=>{
    text += m.label+"<br>";
  });
  document.getElementById("memoryLog").innerHTML=text;
}

showMemory();
</script>

</body>
</html>
