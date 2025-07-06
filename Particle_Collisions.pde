
// We're in Java so it doesn't really matter, but let's try it the ECS way
PVector[] particles;
PVector[] velocities;
float[] radii;
float[] masses;
color[] colors;
int numOfParticles=150;
float tickRate = 1.0f/60.0f;
float lastMillis=0;

void setup() {
  frameRate(120);
  size(900, 700);
  particles = new PVector[numOfParticles];
  velocities = new PVector[numOfParticles];
  radii = new float[numOfParticles];
  masses = new float[numOfParticles];
  colors = new color[numOfParticles];
  colorMode(HSB);
  for (int i = 0; i<numOfParticles; i++) {
    masses[i] = random(0.5f, 6);
    radii[i] = sqrt(masses[i])*6;
    particles[i] = new PVector(random(-width/2, width/2), random(-height/2, height/2));
    velocities[i] = PVector.random2D().mult(40);
    colors[i] = color(random(255), 255, 255);
  }
}
float deltaT=0;

void draw() {
  background(25);
  //text(frameRate, 0, 10);
  noStroke();
  translate(width/2, height/2);
  float currentMillis = millis();
  deltaT += (currentMillis - lastMillis) / 1000f;
  lastMillis = currentMillis;

  Boolean shouldPhysicsTick=false;
  if (deltaT > tickRate) {
    shouldPhysicsTick = true;
  }
  for (int i=0; i<numOfParticles; i++) {
    PVector p = particles[i];
    PVector vel = velocities[i];
    float radius = radii[i];

    if (shouldPhysicsTick) {
      CheckCollision(i);
      Move(p, vel);
      deltaT = 0;
    }
    stroke(colors[i]);
    circle(p.x, p.y, radius*2);
  }
}
void CheckCollision(int index) {
  PVector p1 = particles[index];
  float r1 = radii[index];
  float m1 = masses[index];
  PVector v1 = velocities[index];
  CheckWalls(p1, v1, r1);
  for (int i=index+1; i<numOfParticles; i++) {
    if (i==index) {
      continue;
    }
    PVector p2 = particles[i];
    float r2 = radii[i];
    float m2 = masses[i];
    PVector v2 = velocities[i];
    float sumR = r1+r2;
    float sumRSqr = (sumR)*(sumR);
    PVector deltaP = PVector.sub(p1, p2);
    float dist2 = deltaP.magSq();
    if (deltaP.magSq()>sumRSqr) {
      continue;
    }
    float relVel = PVector.dot(v1.copy().sub(v2), deltaP);
    if (relVel >= 0) {
      continue;
    }
    float den = (m1+m2)* dist2;

    p1 = particles[index];
    p2 = particles[i];
    PVector deltaPA = PVector.sub(p2, p1);
    PVector deltaPB = PVector.sub(p1, p2);
    //Particle a
    PVector vDiffA = PVector.sub(v2, v1);
    float numA = PVector.dot(vDiffA, deltaPA);
    float facA = (2 * m2 * numA)/den;
    PVector deltaVA = PVector.mult(deltaPA, facA);
    //Particle b
    PVector vDiffB = PVector.sub(v1, v2);
    float numB = PVector.dot(vDiffB, deltaPB);
    float facB = (2 * m1 * numB)/den;
    PVector deltaVB = PVector.mult(deltaPB, facB);

    velocities[index].add(deltaVA);
    velocities[i].add(deltaVB);
  }
}
void CheckWalls(PVector p1, PVector v1, float r1) {
  if (p1.x+r1>width/2) {
    v1.x*=-1;
    p1.x = width/2-r1;
  } else if (p1.x-r1< -width/2) {
    v1.x*=-1;
    p1.x = -width/2+r1;
  }
  if (p1.y+r1>height/2) {
    v1.y*=-1;
    p1.y = height/2-r1;
  } else if (p1.y-r1<-height/2) {
    v1.y*=-1;
    p1.y = -height/2+r1;
  }
}
void Move (PVector particle, PVector velocity) {
  particle.x+=velocity.x * tickRate;
  particle.y+=velocity.y * tickRate;
}
