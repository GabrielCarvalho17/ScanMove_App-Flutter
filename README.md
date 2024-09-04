
# ScanMove (App de Gestão de Estoque de Matéria-Prima)

**ScanMove** é um aplicativo Android desenvolvido em Flutter, projetado para facilitar a movimentação de matéria-prima no estoque de tecidos de fábricas. Seu principal objetivo é agilizar o fluxo de trabalho dos operadores, eliminando a necessidade de anotações manuais em planilhas e a posterior inserção de dados no sistema ERP.

Link para a documentação: https://drive.google.com/drive/folders/1CqxSvRL9Recws71FklQgSesCyVGNb1gO?usp=drive_link

## Funcionalidades

- **Escaneamento de códigos de barras**: Escaneia os códigos de barras dos produtos no estoque.
- **Registro de origem e destino**: Escaneia as localizações de origem e destino dentro do estoque.
- **Processo simplificado**: Gravar e finaliza o processo de movimentação de forma rápida e eficiente.
- **Copia Offline Segura**: Armazena temporariamente os dados no banco de dados local (SQLite), garantindo que, em caso de falha na comunicação com a API, as informações sejam preservadas e sincronizadas corretamente assim que a conexão for restabelecida.
- **Sincronização via API RestFull**: Se comunica diretamente com uma API RestFull, garantindo que as informações estejam de forma segura e eficiente.

## Tecnologias

- **Flutter 3.22.2**: Framework utilizado para o desenvolvimento do aplicativo.
- **Dart 3.4.3**: Linguagem de programação usada junto com o Flutter.
- **API RestFull em Django**: Backend utilizado para sincronização das movimentações, garantindo comunicação entre o aplicativo e o sistema.

## Pré-requisitos

- **Android 5.0 (Lollipop)** ou superior (minSdkVersion 21)
- **Android 14** como versão alvo (targetSdkVersion 34)
- O backend (API RestFull) deve estar configurado e acessível para permitir a sincronização das movimentações.


## Como Iniciar

### Passo 1: Configurar o ambiente de desenvolvimento

Certifique-se de que possui as seguintes ferramentas instaladas no seu ambiente de desenvolvimento:

- [Flutter](https://flutter.dev/docs/get-started/install) versão 3.22.2
- [Android Studio](https://developer.android.com/studio) ou outro editor compatível com Flutter

### Passo 2: Clonar o repositório

Clone o repositório do projeto em sua máquina local:

```bash
git clone https://github.com/seu-usuario/scanmove.git
cd scanmove
```

### Passo 3: Instalar as dependências do projeto

Após clonar o repositório, instale as dependências necessárias para que o projeto funcione corretamente. Na raiz do projeto, execute o seguinte comando:

```bash
flutter pub get
```

### Passo 4: Gerar o APK para instalação

Para gerar o APK e instalá-lo em um dispositivo Android, utilize o seguinte comando:

```bash
flutter build apk
```

O arquivo APK será gerado na pasta `build/app/outputs/flutter-apk/`. Transfira-o para o seu dispositivo Android e instale-o manualmente.

## Testes e Modo de Depuração

### Iniciar o aplicativo em modo de depuração

Para iniciar o aplicativo no modo de depuração em um dispositivo Android ou emulador, siga os passos abaixo:

1. Conecte seu dispositivo Android ou inicie um emulador.
2. No terminal, dentro do diretório do projeto, execute o seguinte comando:

```bash
flutter run

