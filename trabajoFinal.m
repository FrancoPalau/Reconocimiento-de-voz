%function trabajoFinal
    contKmeans=0;
    contKNN=0;
    errKmeans=0;
    errKNN=0;
    activado=true;
    opciones = input('1_Grabar nueva base de datos \n2_Usar base de datos existente \n');
    if (opciones == 1)
        grabarBaseDatos;
        AudiosProcesados=procesarBaseDeDatos;
        DisplayBaseDeDatos(AudiosProcesados);
    elseif (opciones == 2)
        AudiosProcesados=procesarBaseDeDatos;
        DisplayBaseDeDatos(AudiosProcesados);    
    end

    while (activado)
        opciones2 = input('0_Salir \n1_ K-MEANS \n2_ K-NN\n');
        if (opciones2 == 0)
            activado = false;
        elseif (opciones2 == 1)
            disp('K-Means');
            contKmeans = contKmeans + 1;
            grabarAudioActual;
            audioActualProcesado=procesarAudioActual;
            [C1,C2,C3,CN,K,I]=myKmeans(audioActualProcesado,AudiosProcesados);
            arduinoControl(I);
            Error=input('1-Lectura correcta \n2-Lectura incorrecta \n');
            if (Error == 2)
                errKmeans=errKmeans+1;
            end
        elseif (opciones2 == 2)
            disp('K-NN');
            contKNN = contKNN + 1;
            %grabarAudioActual;
            audioActualProcesado=procesarAudioActual;
            [grupos,I]=knn(audioActualProcesado,AudiosProcesados);
            arduinoControl(I);
            Error=input('1-Lectura correcta \n2-Lectura incorrecta \n');
            if (Error == 2)
                errKNN=errKNN+1;
            end
        end    
    end
    
    fprintf('Porcentaje de Error con K-means: %g\n',(errKmeans*100/contKmeans));
    fprintf('Porcentaje de Error con Knn: %g\n',(errKNN*100/contKNN)); 
    
%end

function grabarBaseDatos
    for(i=1:9)
        recObj = audiorecorder(44100,16,1); %objeto recObj, param(rate,bits,stereo)
        disp(strcat('Comience a hablar ',num2str(i)));
        recordblocking(recObj, 2); %segundo parametro tiempo de grabacion
        disp('Fin de la grabación.');
        % almacena los datos en un arreglo de doble precisión.
        myRecording = getaudiodata(recObj);
        audiowrite(strcat('Audio', num2str(i), '.wav'),myRecording,44100);
    end
end

function [CRecordings]=procesarBaseDeDatos  
     for i=1:9
         Recordings = audioread(strcat('Audio', num2str(i), '.wav'));
         CRecordings(:,i)=rceps(Recordings(:,1));
         CRecordings(:,i)=CRecordings(:,i)./max(CRecordings(:,i));
         %CRecordings(:,i) = Recordings;
     end
end

function grabarAudioActual
    % Grabe su voz por 2 segundo
    recObj = audiorecorder(44100,16,1); %objeto recObj, param(rate,bits,stereo)
    disp('Comience a hablar.')
    recordblocking(recObj, 2); %segundo parametro tiempo de grabacion
    disp('Fin de la grabación.');
    % almacena los datos en un arreglo de doble precisión.
    myRecording = getaudiodata(recObj);
    %se crea un archivo de audio con el arreglo
    audiowrite('AudioActual.wav',myRecording,44100);
end

function [cepstrum]=procesarAudioActual   
    myRecording=audioread('AudioActual.wav');
    cepstrum=rceps(myRecording);
    %Normalizamos
    cepstrum(:,1)=cepstrum(:,1)./max(cepstrum(:,1));
    %cepstrum(:,2)=cepstrum(:,2)./max(cepstrum(:,2));
    %cepstrum = myRecording;
end

function DisplayBaseDeDatos(AudiosProcesados)
    figure(1)
    for (i = 1 : 9)
        Recordings = audioread(strcat('Audio', num2str(i), '.wav'));
        subplot(3,3,i)
        if i < 4
            plot(Recordings,'r');
        elseif i >= 4 && i < 7
            plot(Recordings,'g');
        else
            plot(Recordings,'y');
        end
    end   
    t=0:length(Recordings)-1;
    figure(2)
    for (i = 1 : 9)
        subplot(3,3,i)
        if i < 4
            plot(t,AudiosProcesados(:,i),'r');
        elseif i >= 4 && i < 7
            plot(t,AudiosProcesados(:,i),'g');
        else
            plot(t,AudiosProcesados(:,i),'y');
        end
    end
    
    figure(3)
    for (i = 1 : 9)
        subplot(3,3,i)
        if i < 4
            histogram(AudiosProcesados(:,i));
        elseif i >= 4 && i < 7
            histogram(AudiosProcesados(:,i));
        else
            histogram(AudiosProcesados(:,i));
        end
    end          
end

function [grupos,I]=knn(audioActual,baseDeDatos)
    grupos=[1;1;1;2;2;2;3;3;3];
    %grupos=[1;1;1;1;1;1;2;2;2;2;2;2;3;3;3;3;3;3];
    %Class = knnclassify(audioActual',baseDeDatos',grupos); 
    Mdl=fitcknn(baseDeDatos',grupos);
    Class=predict(Mdl,audioActual(:,1)');
    %disp(Class)
    I=Class(1,1);
end

function [C1,C2,C3,CN,K,I]=myKmeans(audioActual,baseDeDatos)
    for (i=1:3)
        X1(i,:) = baseDeDatos(:,i);   %rojos
        X2(i,:) = baseDeDatos(:,i+3); %verdes
        X3(i,:) = baseDeDatos(:,i+6); %amarillos
    end
    
    [idx1,C1] = kmeans(X1,1,'Distance','cosine','Start','plus');
    centros_filas1 = find(abs(C1) > 0.04);
    [idx2,C2] = kmeans(X2,1,'Distance','cosine','Start','plus');
    centros_filas2 = find(abs(C2) > 0.04);
    [idx3,C3] = kmeans(X3,1,'Distance','cosine','Start','plus');
    centros_filas3 = find(abs(C3) > 0.04);
    
    [idxN,CN] = kmeans(audioActual',1,'Distance','cosine','Start','plus');
    centroides=[C1;C2;C3];
    centros_filasN = find(abs(CN) > 0.04);
    
    for (j=1:3)
        for (i=1:88200)
            diferencia(j,i) = abs(centroides(j,i) - CN(1,i)); 
        end
    end
    K=sum(diferencia');
    [M,I] = min(K);
    
    %display
    figure(4)
    plot(C1(centros_filas1),'r.','MarkerSize',12)
    hold on
    plot(C2(centros_filas2),'g.','MarkerSize',12)
    plot(C3(centros_filas3),'y.','MarkerSize',12)
    plot(CN(centros_filasN),'kx',...
     'MarkerSize',15,'LineWidth',3)
    legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
    title 'Cluster Assignments and Centroids'
    hold off

end

function arduinoControl(I)
    a=arduino();
    RED_PIN='D12';
    GREEN_PIN='D6';
    YELLOW_PIN='D9';
    writeDigitalPin(a,RED_PIN,0);
    writeDigitalPin(a,GREEN_PIN,0);
    writeDigitalPin(a,YELLOW_PIN,0); 
    if I == 1
        disp('ROJO');
        writeDigitalPin(a,RED_PIN,1);
        pause(2);
    elseif I == 2
        disp('GRIS');
        writeDigitalPin(a,GREEN_PIN,1);
        pause(2);
    elseif I == 3
        disp('AMARILLO');
        writeDigitalPin(a,YELLOW_PIN,1);
        pause(2);
    end
    clear a;
end