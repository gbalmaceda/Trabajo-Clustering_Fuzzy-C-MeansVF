%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%         Máster en Ingeniería Informática - UCLM                       %%
%%         Diseño de Sistemas Inteligentes - TRABAJO CLUSTERING          %%
%                                                                         %
%Elaborado por: -Balmaceda Torres, Gustavo Adolfo                         %
%               -Fernández Martínez, Javier                               %
%                                                 Ciudad Real, Marzo/2018 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all, clear, clc   % Cerrar ventanas gráficas y borrar memoria/consola
%La variable ComunProvMun almacena información general de las comunidades,
%Provincia y Municipios.
ComunProvMun=xlsread('DatosNum_Renta.xlsx','A2:G1110');
% NORMALIZANDO DATOS DE POBLACIÓN DE COMUNIDADES: 
% Población (INE) y Población declarante (IRPF)
PoblacionINE_IRPF(:,1)=(ComunProvMun(:,6)-mean(ComunProvMun(:,6)))/std(ComunProvMun(:,6));
PoblacionINE_IRPF(:,2)=(ComunProvMun(:,7)-mean(ComunProvMun(:,7)))/std(ComunProvMun(:,6));
%
% Leer las siguientes columnas: Renta imponible agregada (IRPF)
% Renta imponible media por declarante y por habitante respectivamente
R_imponible_yMedias=xlsread('DatosNum_Renta.xlsx','H2:J1110');
% NORMALIZANDO RENTAS
for i=1:size(R_imponible_yMedias,2)
    R_imponible_yMedias(:,i)=(R_imponible_yMedias(:,i)-mean(R_imponible_yMedias(:,i)))/std(R_imponible_yMedias(:,i));
end
%
%Leer Desigualdades
Desigualdades=xlsread('DatosNum_Renta.xlsx','K2:L1110');
%Leer Concentración de renta 1%. 
%Se consideró únicamente leer la concentración de renta - Top 1%
ConcentracionRenta1=xlsread('DatosNum_Renta.xlsx','M2:M1110');
%Leer Distribución de Renta- Quintil 1, 2, 3, 4 y 5
DistribRenta=xlsread('DatosNum_Renta.xlsx','P2:T1110');
%
%%%%%%%%%%%%%%%%DATOS A ANALIZAR Y AGRUPADOS%%%%%%%%%%%%%%%%%%%%
DatosFinales= [PoblacionINE_IRPF R_imponible_yMedias(:,1) Desigualdades(:,1)]%Genera 4 Grupos
%
%Otras agrupaciones probadas:
%DatosFinales= [PoblacionINE_IRPF(:,1) R_imponible_yMedias(:,1)]%Genera 4 Grupos
%DatosFinales= [PoblacionINE_IRPF(:,1) PoblacionINE_IRPF(:,2)]%Genera 5 Grupos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% APLICANDO   ALGORITMO   F u z z y   c - m e d i a s  y B I C%%
% BIC- Permite calcular la cantidad de grupos óptimos a         %
%considerar en el Algorintmo                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kmax=10;
for K=2:Kmax
    m=2;                   % parámetro de fcm, 2 es el defecto
MaxIteraciones=100;        % número de iteraciones
Tolerancia= 1e-5;          % tolerancia en el criterio de para
Visualizacion=0;           % 0/1
opciones=[m,MaxIteraciones,Visualizacion];
[center,U,obj_fcn] = fcm(DatosFinales, K,opciones);
% Parámetros de salida:              
% center    centroides de los grupos
% U         matriz de pertenencia individuo cluster 
% obj_fun   función objetivo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Asignación de individuo a grupo, maximizando el nivel de 
%pertenencia al grupo
for j=1:K
maxU=max(U); % calculo del máximo nivel de pertenencia de los individuos
individuos=find(U(j,:)==maxU)% calcula los individuos del grupo i que alcanzan el máximo
cidx(individuos)=j;           % asigna estos individuos al grupo i
grado_pertenecia(individuos)=maxU(individuos);
end
[Bic_K,xi]=BIC(K,cidx,DatosFinales);
BICK(K)=Bic_K;
end
%La Figura 1 representa el valor que "K" debe tener para el algoritmo
figure(1)
plot(2:K',BICK(2:K)','s-','MarkerSize',6,...
     'MarkerEdgeColor','r', 'MarkerFaceColor','r')
xlabel('K','fontsize',18)      % etiquetado del eje-x
ylabel('BIC(K)','fontsize',18) % etiquetado del eje-y
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CALCULANDO FUZZY CON VALOR DE GRUPOS OPTIMOS%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K_Optimo=find(BICK(1:Kmax)==min(BICK(2:Kmax)))
[center,U,obj_fcn] = fcm(DatosFinales, K_Optimo,opciones);
for i=1:K_Optimo
maxU=max(U); % calculo del máximo nivel de pertenencia de los individuos
individuos=find(U(i,:)==maxU);% calcula los individuos del grupo i que alcanzan el máximo
cidx(individuos)=i;           % asigna estos individuos al grupo i
grado_pertenecia(individuos)=maxU(individuos);
end
%% Figura 2- Representación de individuos
figure(2)
plot(DatosFinales(cidx==1,1),DatosFinales(cidx==1,2),'s','MarkerSize',6,...
                  'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on
plot(DatosFinales(cidx==2,1),DatosFinales(cidx==2,2),'^','MarkerSize',6,...
                  'MarkerEdgeColor','b', 'MarkerFaceColor','b');
hold on
plot(DatosFinales(cidx==3,1),DatosFinales(cidx==3,2),'o','MarkerSize',6,...
                  'MarkerEdgeColor','y','MarkerFaceColor','y');
hold on
plot(DatosFinales(cidx==4,1),DatosFinales(cidx==4,2),'*','MarkerSize',6,...
                  'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on
title('Algoritmo Fuzzy c-means- Agrupaciones','fontsize',16)
%%Figura 3- Se definen formatos para diferencias cada uno de los CIDX encontrados 
%%Considerando el número de filas del archivo Excel se dan formatos por
%%cada municipio
figure(3)
cidx=cidx'
for i=1:size(cidx)
if cidx(i)==1
    if i<=237
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
    elseif (i>237) && (i<=257)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
    elseif (i>257) && (i<=288)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');
    elseif (i>288) && (i<=325)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    elseif (i>325) && (i<=390)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
    elseif (i>390) && (i<=407)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
    elseif (i>407) && (i<=459)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','k');
    elseif (i>459) && (i<=523)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','w');
    elseif (i>523) && (i<=703)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','w');
    elseif (i>703) && (i<=742)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','w');
    elseif (i>742) && (i<=859)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','w');
    elseif (i>859) && (i<=928)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','w');
    elseif (i>929) && (i<=960)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','w');
    elseif (i>960) && (i<=969)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','w');
    elseif (i>969) && (i<=1108)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor',[1 0.4 0.6]);
    elseif (i==1109)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','w');
    else
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','k');
    end
elseif cidx(i)==2
    if i<=237
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
    elseif (i>237) && (i<=257)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
    elseif (i>257) && (i<=288)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');
    elseif (i>288) && (i<=325)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    elseif (i>325) && (i<=390)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
    elseif (i>390) && (i<=407)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
    elseif (i>407) && (i<=459)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','k');
    elseif (i>459) && (i<=523)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','w');
    elseif (i>523) && (i<=703)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','w');
    elseif (i>703) && (i<=742)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','w');
    elseif (i>742) && (i<=859)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','w');
    elseif (i>859) && (i<=928)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','w');
    elseif (i>929) && (i<=960)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','w');
    elseif (i>960) && (i<=969)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','w');
    elseif (i>969) && (i<=1108)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor',[1 0.4 0.6]);
    elseif (i==1109)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','w');
    else
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'^', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','k');
    end
if cidx(i)==3
    if i<=237
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
    elseif (i>237) && (i<=257)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
    elseif (i>257) && (i<=288)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');
    elseif (i>288) && (i<=325)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    elseif (i>325) && (i<=390)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
    elseif (i>390) && (i<=407)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
    elseif (i>407) && (i<=459)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','k');
    elseif (i>459) && (i<=523)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','w');
    elseif (i>523) && (i<=703)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'s', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','w');
    elseif (i>703) && (i<=742)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','w');
    elseif (i>742) && (i<=859)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','w');
    elseif (i>859) && (i<=928)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','w');
    elseif (i>929) && (i<=960)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','w');
    elseif (i>960) && (i<=969)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','w');
    elseif (i>969) && (i<=1108)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor',[1 0.4 0.6]);
    elseif (i==1109)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','w');
    else
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'o', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','k');
    end
else
    if i<=237
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
    elseif (i>237) && (i<=257)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
    elseif (i>257) && (i<=288)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');
    elseif (i>288) && (i<=325)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
    elseif (i>325) && (i<=390)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
    elseif (i>390) && (i<=407)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
    elseif (i>407) && (i<=459)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','k');
    elseif (i>459) && (i<=523)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','w');
    elseif (i>523) && (i<=703)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','w');
    elseif (i>703) && (i<=742)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','w');
    elseif (i>742) && (i<=859)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','w');
    elseif (i>859) && (i<=928)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','w');
    elseif (i>929) && (i<=960)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','w');
    elseif (i>960) && (i<=969)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor','k', 'MarkerFaceColor','w');
    elseif (i>969) && (i<=1108)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor',[1 0.4 0.6]);
    elseif (i==1109)
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','w');
    else
    hold on
    plot(DatosFinales(i,1),DatosFinales(i,2),'*', ...
    'MarkerSize',6,'MarkerEdgeColor',[1 0.4 0.6], 'MarkerFaceColor','k');
    end
box on
end
end
end
title('Algoritmo Fuzzy c-means','fontsize',16)
% Escritura del nivel de pertenencia de cada individuo- Se puede ejecutar
% este código si se desea ubicar leyendas. Para claridad del gráfico no se
% representa. 
% for i=1:size(DatosFinales,1)
%     text(DatosFinales(i,1),DatosFinales(i,2),num2str(grado_pertenecia(i)),'FontSize',8);
% end
% print(1,'-depsc','resul_fcm')   % genera gráfico .eps en fichero   