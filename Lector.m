%%%codigo generado por interfaz
function varargout = Lector(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Lector_OpeningFcn, ...
                   'gui_OutputFcn',  @Lector_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%%Seleccion de la interfaz
function Lector_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = Lector_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;
%%boton cargar imagen toma la imagen que este en el axes1 lo guarda en la
%%variable img, luego la muestra en el axes1 (en la interfaz es el cuadro blanco)
function btncargarimagen_Callback(~, ~, handles)
[FileName, ~]=uigetfile({'*.jpg;*.bmp;*.png'},'Seleccionar Huella');
img = imread(FileName);
axes(handles.axes1);
imshow(img);
set(handles.axes1, 'UserData', img);
%%El adelgazamiento de crestas es eliminar los píxeles redundantes de las crestas hasta que las crestas tengan solo un píxel de ancho.
function btnadelgazar_Callback(~, ~, handles)
img=get(handles.axes1,'UserData'); %%toma la imagen
J=img(:,:,1)>160;  %%todas las filas y columnas de la imagen (img) de la primera pagina 
K=bwmorph(~J,'thin','inf');%%funcion adelgazar e infinito
imshow(~K) %% operador logico not (muestra el resultado de K inverso)
set(handles.axes1, 'UserData', img); %% lo posiciona en el axes1
%%%resalta los surcos/hendiduras de la imagen
function btnbinarizacion_Callback(~, ~, handles)
img=get(handles.axes1,'UserData');
J=img(:,:,1)>160;
imshow(J)
set(handles.axes1, 'UserData', img);
%%las terminaciones 
function btnterminaciones_Callback(~, ~, handles)
img=get(handles.axes1,'UserData');
J=img(:,:,1)>160;
K=bwmorph(~J,'thin','inf'); %% fuencion adelfazamient
img2 = bwmorph(K,'skel',Inf); %% función esqueletizacion 
img3 = bwmorph(img2,'endpoints',Inf); %%fuencion puntos finales
imshow(img3)
set(handles.axes1, 'UserData', img3);
function btnguardar_Callback(~, ~, handles)
img=get(handles.axes1,'UserData');
imshow(img)
name = get(handles.txtnombre, 'String');  %%toma lo que esta en nombre
lastname = get(handles.txtapellido, 'String');  %%toma lo que esta en apellido
id = get(handles.txtcedula, 'String');  %%toma lo que esta en cédula
name2 = 'C:\Users\loren\Desktop\Matlab\17Septiembre\Guardadas\'; %%ruta donde se guarda las imagenes 
name3 = strcat(name, lastname, id); %%concatenacion para el nombre
ext = '.jpg'; 
nameimg = strcat(name2, name3, ext); %%concatenacion de nombre y extension
disp (nameimg) 
[i j]=size(img); 
    huella2=zeros(i+2,j+2); %%medidas de la imagen que esta en el axes1 (marco)
    [n m]=size(huella2);%%fila 
    huella2(2:n-1,2:m-1)=img(1:i,1:j);%%columna
    endpoint1=0; %% punto final
    branchpoint1=0; %%punto de interes 
    bottompoint1=0;%% valles 
    toppoint1=0; %% crestas
    %Generacion de patrones/vectores de reconocimiento
    for m=2:m-1
        for n=2:n-1
            %Generar una mascara de 3x3 para cada pixel
            mascara=huella2(n-1:n+1,m-1:m+1);
            contador=0; %contador que cuenta números 1
        
            %Bucle, se cuentan los 1 en cada máscara
            for j=1:3
                for i=1:3
                    if mascara(i,j)==1
                    contador=contador+1; 
                    end
                end
            end
        
            %Condicionantes para contar puntos de interés
            if contador==2 && mascara(2,2)==1 %si existen solamente dos 1, es un punto final
            endpoint1=endpoint1+1;
            elseif contador==4 && mascara(2,2)==1 %si existen cuatro 1, es una bifurcaciÃ³n
                branchpoint1=branchpoint1+1;
            end
        
            if mascara==[1 0 1;0 1 0;0 0 0] %Se cuentan los valles
                bottompoint1=bottompoint1+1;
            elseif mascara==[0 0 0;0 1 0;1 0 1] %Se cuentan las crestas
                toppoint1=toppoint1+1;
            end
        
        end
    end
    v1=[toppoint1 bottompoint1 branchpoint1 endpoint1];
    disp (v1)
    
imwrite (img, nameimg);%% guarda a imagen con el nuevo nombre
%%llama interfaz guardo
guardo
function btnenviar_Callback(~, ~, handles)
name = get(handles.txtnombre, 'String');
set(handles.lblnombre2,'String', name);
lastname = get(handles.txtapellido, 'String');
set (handles.lblapellido2, 'String', lastname);
id = get(handles.txtcedula, 'String');
set (handles.lblcedula2, 'String', id);
img=get(handles.axes1,'UserData');
J=img(:,:,1)>160;
%Conexion
conexion = database('lectorjdbc','root','12345');
exdata1={id, name, lastname, img};
colnames1={'id', 'nombre', 'apellido', 'huella'};
%insert(conexion,'lector',colnames1,exdata1);
fastinsert(conexion,'lector',colnames1,exdata1)
close (conexion);
% datosenviar={id, name, lastname, img};
% columnas={'id', 'nombre', 'apellido', 'huella'};
% insert(conexion, 'lector', columnas, datosenviar);
% close (conexion);
%fin de bloque conexion
msgbox('Se ha registrado correctamente' , 'Mensaje');
function txtnombre_Callback(~, ~, ~)
function txtnombre_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function txtapellido_Callback(~, ~, ~)
function txtapellido_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function txtcedula_Callback(~, ~, ~)
function txtcedula_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function btnvalidacion_Callback(~, ~, handles)
%%se toma la imagen a validaar
img=get(handles.axes1,'UserData');
imshow(img)
%Agregar marco, filas y columna
[i j]=size(img);
huella2=zeros(i+2,j+2);
[n m]=size(huella2);
huella2(2:n-1,2:m-1)=img(1:i,1:j);
%Puntos de interés, para reconocimiento
endpoint1=0;
branchpoint1=0;
bottompoint1=0;
toppoint1=0;
%Generación de patrones/vectores de reconocimiento
for m=2:m-1
    for n=2:n-1
        %Generar una máscara de 3x3 para cada pixel
        mascara=huella2(n-1:n+1,m-1:m+1);
        contador=0; %contador que cuenta números 1
        
        %Bucle, se cuentan los 1 en cada máscara
        for j=1:3
            for i=1:3
                if mascara(i,j)==1
                   contador=contador+1; 
                end
            end
        end
        
        %Condicionantes para contar puntos de interés
        if contador==2 && mascara(2,2)==1 %si existen solamente dos 1, es un punto final
           endpoint1=endpoint1+1;
        elseif contador==4 && mascara(2,2)==1 %si existen cuatro 1, es una bifurcación
            branchpoint1=branchpoint1+1;
        end
        
        if mascara==[1 0 1;0 1 0;0 0 0] %Se cuentan los valles
            bottompoint1=bottompoint1+1;
        elseif mascara==[0 0 0;0 1 0;1 0 1] %Se cuentan las crestas
            toppoint1=toppoint1+1;
        end
        
    end
end
v1=[toppoint1 bottompoint1 branchpoint1 endpoint1];
disp (v1)
%%leera los archivos que se envientre en la carpeta de las imagenes que ya
%%estan guardadas 
lee_archivos = dir('C:\Users\loren\Desktop\Matlab\17Septiembre\Guardadas\*.jpg');
for k = 1:length(lee_archivos) %recorre número de archivos guardados en el directorio
    archivo = lee_archivos(k).name; %Obtiene el nombre de los archivos
    nombre = 'C:\Users\loren\Desktop\Matlab\17Septiembre\Guardadas\'; %Recorre el diretorio
    imagen = imread(strcat(nombre,archivo));% lee las imagenes
    %disp('Nombre del archivo: ')
    disp(archivo)
    
    %Agregar marco, filas y columna
[i j]=size(imagen);
huella2=zeros(i+2,j+2);
[n m]=size(huella2);
huella2(2:n-1,2:m-1)=imagen(1:i,1:j);
%Puntos de interés, para reconocimiento
endpoint1=0;
branchpoint1=0;
bottompoint1=0;
toppoint1=0;
%Generación de patrones/vectores de reconocimiento
for m=2:m-1
    for n=2:n-1
        %Generar una máscara de 3x3 para cada pixel
        mascara=huella2(n-1:n+1,m-1:m+1);
        contador=0; %contador que cuenta números 1
        
        %Bucle, se cuentan los 1 en cada máscara
        for j=1:3
            for i=1:3
                if mascara(i,j)==1
                   contador=contador+1; 
                end
            end
        end
        
        %Condicionantes para contar puntos de interés
        if contador==2 && mascara(2,2)==1 %si existen solamente dos 1, es un punto final
           endpoint1=endpoint1+1;
        elseif contador==4 && mascara(2,2)==1 %si existen cuatro 1, es una bifurcación
            branchpoint1=branchpoint1+1;
        end
        
        if mascara==[1 0 1;0 1 0;0 0 0] %Se cuentan los valles
            bottompoint1=bottompoint1+1;
        elseif mascara==[0 0 0;0 1 0;1 0 1] %Se cuentan las crestas
            toppoint1=toppoint1+1;
        end
        
    end
end
v2=[toppoint1 bottompoint1 branchpoint1 endpoint1];
disp (v2)

if v1==v2
    %%llama interfaz existente 
    existente
else 
    disp ('La imagen no cohincide con el archivo')
end
end
