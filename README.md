# Speech Recognition

This project consists of the design and implementation of a learning agent for later use in a robot responsible for painting mechanical parts. To achieve this, the agent receives by voice commands the three colors to be painted: Red, Green and Yellow. In these cases the agent must know how to differentiate each word to be able to paint the piece of the corresponding color. For this, two learning algorithms were used, Kmeans and K-NN, where the performance of each one was then evaluated. To apply the algorithms, the values were taken from the inverse Fourier transform of the sound signal spectrum, also called "Cepstrums". The implementation of the algorithms was done in MatLab and the prototype was developed on an Arduino Uno board

![alt text](https://github.com/FrancoPalau/Reconocimiento-de-voz/blob/master/imagen5.jpg)
