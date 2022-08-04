Esse é o quinto post da série **Meu primeiro smart contract**, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.

Nesse post vamos entender o que é o hardhat e aprender a subir nosso contrato para uma rede de teste (testnet) utilizando o Alchemy para nos ajudar nessa parte.

## Ferramentas

Nesse post vamos utilizar o [VS Code](https://code.visualstudio.com/download) para editar o código, o [Node.js](https://nodejs.org/en/download/) para instalar e executar o código, o [Alchemy](https://www.alchemy.com/) para nos ajudar a subir nosso contrato para uma rede de teste e a [Metamask](https://metamask.io/) para administrarmos nossas carteiras.

## Hardhat

Hardhat é um ambiente de desenvolvimento para software Ethereum. Ele consiste em diferentes componentes para editar, compilar, depurar e implantar seus contratos inteligentes e dApps, todos trabalhando juntos para criar um ambiente de desenvolvimento completo.

O Hardhat Runner é o principal componente com o qual você interage ao usar o Hardhat. É um executor de tarefas flexível e extensível que ajuda você a gerenciar e automatizar as tarefas recorrentes inerentes ao desenvolvimento de contratos inteligentes e dApps.

> Caso queira saber mais sobre o Hardhat, clique [aqui](https://hardhat.org/tutorial) que é um tutorial de hardhat para iniciantes.

## Instalação

No terminar do VS Code:
1 - Vamos criar o `package.json` com uma configuração base:

```bash
npm init -y
```

2 - Vamos instalar o `hardhat` como dependência de desenvolvimento:

```bash
npm install --save-dev hardhat
```

3 - Vamos criar um novo projeto:

```bash
npx hardhat
```

3.1 - Esse comando irá te fazer algumas perguntas para saber que tipo de projeto você deseja criar, vamos criar um projeto JavaScript:

```
What do you want to do?
┗ Create a JavaScript project
```

3.2 - Onde você deseja criar o projeto do hardhat:

```
Hardhat project root:
┗ Enter
```

3.3 - Se deseja criar o arquivo `.gitignore`:

```
Do you want to add a .gitignore?
┗ Y
```

3.4 - Se deseja compartilhar as informações do seu projeto com o Hardhat:

```
Help us improve Hardhat with anonymous crash reports & basic usage data?
┗ N
```

3.5 - Se deseja já instalar as dependências do projeto:

```
Do you want to install this sample project's dependencies with npm (@nomicfoundation/hardhat-toolbox)?
┗ Y
```

Após executar esses comandos o hardhat vai ter criado uma um projeto base para nós conseguirmos trabalhar.

![Arquivos criado até agora](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/c9hm6tdxahdg9jzh23lh.png)

Vamos dar uma olhada nos arquivos que o hardhat criou e entender cada um deles.

## Contracts

Dentro da pasta `contracts` é o lugar onde criamos nossos contratos inteligentes, vamos dar uma olhada no contrato `Lock`.

### Lock

Esse contrato que o hardhat criou como exemplo, nos permite travar uma quantia de ether por um determinado tempo dentro do nosso contrato e depois que passar o tempo definido vamos conseguir retirar essa quantidade de ether.
Vamos mudar algumas coisas para seguir o mesmo padrão que utilizamos nos posts anteriores.
Dentro do arquivo `Lock.sol` vamos mudar a licença do contrato para `GLP-3.0`.

```solidity
// SPDX-License-Identifier: GPL-3.0
```

O contrato está importando o arquivo `hardhat/console.sol` que é o arquivo que contém algumas funções que nos permite utilizar o console para nos ajuda a debugar o nosso contrato, nativamente o solidity não tem suporte ao console, então importamos o arquivo `hardhat/console.sol` para que possamos usar o console.

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
```

> Caso queira entender um pouco mais sobre importação de outros contratos, clique [aqui](https://solidity.web3dev.com.br/exemplos/linguagem-v0.8.3/import)

#### Variáveis

O nosso contrato tem duas variáveis: uma para salvar o dono do contrato `owner` e outra para salvar o tempo que será travado a quantidade de ether `unlockTime`.

```solidity
uint public unlockTime;
address payable public owner;
```

#### Evento

Temos um evento para enviar uma informação para o nosso front-end quando realizarmos a retirada de ether do contrato.

```solidity
event Withdrawal(uint amount, uint when);
```

#### Construtor

No constructor estamos fazendo uma verificação para ver se `_unlockTime` é maior que o [`block.timestamp`](https://solidity.web3dev.com.br/apostila/variaveis-built-in-msg.sender-msg.value...#block.timestamp), se for maior que o timestamp do bloco, então salvamos o tempo que o bloco será destravado e o dono do contrato.

```solidity
constructor(uint _unlockTime) payable {
  require(
    block.timestamp < _unlockTime,
    "Unlock time should be in the future"
  );

  unlockTime = _unlockTime;
  owner = payable(msg.sender);
}
```

#### Saldo do contrato

Para facilitar o nosso entendimento mais para frente vamos criar uma função chamada `balanceOf` que retorna o saldo do contrato.

```solidity
function balanceOf() public view returns(uint){
  return address(this).balance;
}
```

#### Retirar Ethers

Antes de retirar os ethers do contrato, é feita uma verificação se o contrato está destravado e se quem chamou a função é o dono do contrato.
Se passar pelas verificações, então é feita a retirada dos Ethers do contrato.

```solidity
function withdraw() public {
  // Uncomment this line to print a log in your terminal
  console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp); // {1}

  require(block.timestamp >= unlockTime, "You can't withdraw yet");
  require(msg.sender == owner, "You aren't the owner");

  emit Withdrawal(address(this).balance, block.timestamp);

  owner.transfer(address(this).balance);
}
```

Na linha {1} podemos descomentar essa linha para verificar o `timestamp` que o contrato será destravado e o `timestamp` atual.

## Scripts

Dentro da pasta `scripts` é o lugar onde podemos escrever scripts para compilar nossos contratos e implementá-los em uma rede ativa ou em uma rede de teste.

## Deploy

Deploy significa implantar, isso quer dizer que quando fazemos um deploy estamos subindo nosso contrato para blockchain para que outras pessoas possam ver nosso contrato e interagir com ele.
Vamos dar uma olhada no arquivo `deploy.js` que é o arquivo que contém todas as informações para subir nosso contrato para a blockchain.

Na variável `hre` estamos realizando uma importação das funções do `hardhat` com o `require` que é uma instrução `node.js` embutida e é mais comumente usada para incluir módulos de outros arquivos separados, resumidamente é mais ou menos igual o `import` que vimos mais cedo.

```javascript
const hre = require("hardhat");
```

O hardhat criou uma [função assíncrona](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Statements/async_function) chamada `main`, quando chamamos uma função assíncrona, ela retorna uma promessa que quando resolvida, retorna o valor que queremos ou um erro caso ocorra algum.

Dentro da função `main` estamos usando a função [`round`](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Math/round) da biblioteca [`Math`](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Math) do JavaScript, ela pega um número decimal e arredonda para baixo e dentro dele estamos pegando o nosso tempo atual dividindo por 1000 para conseguirmos pegar o tempo em milisegundos e salvando tudo isso dentro da variavel `currentTimestampInSeconds`.

```javascript
const currentTimestampInSeconds = Math.round(Date.now() / 1000);
```

Após isso existe uma variável chamada `ONE_YEAR_IN_SECS` que é o tempo que o contrato será destravado em segundos. Vamos mudar essa variável para que o contrato seja destravado em um tempo menor.

```javascript
const ONE_YEAR_IN_SECS = 5 * 60;
```

> Caso queira deixar mudar o nome da variável para ficar igual a operação que está sendo atribuída a ela você pode mudar o nome dela para `FIVE_MINUTES_IN_SECS`.

E no final de tudo vamos somar o valor de `currentTimestampInSeconds` + `FIVE_MINUTES_IN_SECS` e atribuir esse resultado para variável `unlockTime`.

```javascript
const currentTimestampInSeconds = Math.round(Date.now() / 1000);
const FIVE_MINUTES_IN_SECS = 5 * 60;
const unlockTime = currentTimestampInSeconds + FIVE_MINUTES_IN_SECS;
```

Agora vamos mudar a variável `lockedAmount` que agora irá passar 0.01 Ether para o contrato, precisamos mudar a quantidade de ethers que será enviada para o contrato para conseguirmos subir o contrato para blockchain.

```javascript
const lockedAmount = hre.ethers.utils.parseEther("0.01");
```

Na variável `Lock` estamos se conectando ao nosso contrato e na variável `lock` estamos fazendo o deploy do contrato passando o tempo que o contrato ficará travado e a quantidade de Ethers que ficarão travadas.

```javascript
const Lock = await hre.ethers.getContractFactory("Lock");
const lock = await Lock.deploy(unlockTime, { value: lockedAmount });
```

Vamos esperar o deploy do contrato e após isso vamos escrever no console o endereço do contrato que subiu para a blockchain.

```javascript
await lock.deployed();

console.log("Lock with 1 ETH deployed to:", lock.address);
```

O hardhat criou essa função para conseguirmos usar `async/await` em todos os lugares do arquivo e mostrar o erro no console caso aconteça algum.

```javascript
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

## Test

Dentro da pasta `test` é o lugar onde podemos escrever os testes para nossos contratos.
Nos próximos posts vamos entrar em mais detalhes sobre testes.

## Artifacts

Quando um contrato inteligente é compilado com sucesso é criado um arquivo [JSON](https://www.devmedia.com.br/o-que-e-json/23166) para esse contrato, esse arquivo fica salvo na pasta `artifacts`, esse JSON tem informações importantes sobre o contrato de maneira organizada, tais como [bytecode](https://www.zastrin.com/courses/ethereum-primer/lessons/2-7), [ABI](https://www.quicknode.com/guides/solidity/what-is-an-abi), detalhes do deploy, versão, entre outras coisas.
Conseguimos utilizar os JSONs para interagir com algumas bibliotecas e fazer a conexão entre frontend e o contrato, por exemplo.

## Cache

O diretório usado pelo Hardhat para armazenar em cache seus itens internos.

## Node_modules

Dentro da pasta `node_modules` é um diretório criado pelo `npm` ela serve para guardar todos os arquivos das dependências que instalamos no nosso projeto.

## Arquivos

- `.gitignore`: Arquivo que é usado para ignorar arquivos/pastas que não queremos que o git acompanhe.
- `hardhat.config.js`: Arquivo que é usado para configurar o hardhat.
- `package-lock.json`: Arquivo que descreve a árvore exata das dependências que foram geradas para permitir que as instalações subsequentes tenham a árvore idêntica.
- `package.json`: Nesse arquivo armazena as informações básicas sobre as dependências do projeto.
- `README.md`: Arquivo que é usado para documentar o projeto.

## Subindo o contrato para a blockchain

Para conseguirmos subir o contrato para blockchain precisamos fazer algumas coisas antes.

### Dotenv

Abra seu terminal na pasta do nosso projeto, e execute o seguinte comando.

```bash
npm install --save-dev dotenv
```

Com o [dotenv](https://www.npmjs.com/package/dotenv) conseguimos criar variáveis ​​de ambiente para cada ambiente da nossa aplicação.

Crie um um arquivo chamado `.env`, dentro dele vamos criar algumas variáveis de ambiente, fazermos isso porque vamos ter que **utilizar algumas chaves de aplicação que não pode subir para internet**.
![Criando o arquivo .env](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/xp107evaq3ko84evx01m.png)

### Alchemy

No site do [Alchemy](https://www.alchemy.com/), após você ter criado uma conta e se logado, dentro do dashboard clique no botão "Create app"
![Criando um novo projeto no alchemy](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/40okonvhdby88gvn8wzi.png)

Escreva o nome da sua aplicação, escreva uma descrição, selecione a chain "Ethereum", a network "Goerli" e clique em "Create App"
![Criando um novo app no alchemy](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/o34nyvomptgkc5uhkldy.png)

Clicando no nome do projeto vamos ser direcionado para tela da aplicação, onde podemos ter mais informações sobre o uso da aplicação
![Entrando na aplicação](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/nfgpyorghqnhhbvs10w9.png)

Clique em "View key" e copie a chave "HTTPS".
**TOME CUIDADO PARA NÃO COMPARTILHAR ESSAS INFORMAÇÕES COM OUTRAS PESSOAS.**
![Copiando chave https](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/28jpevoehg0l7qvhx08d.png)

Dentro do arquivo `.env` vamos informar nossa chave "HTTPS"

```env
STAGING_ALCHEMY_KEY="COLE AQUI SUA CHAVE HTTPS"
```

### Metamask

Caso você não tenha instalado o [Metamask](https://metamask.io/), de uma olhada nesse [video](https://youtu.be/cSBp71amDZo) que ensina como instalar e configurar a MetaMask.
Com a Metamask configurada, clique na sua "foto" e entre em "settings".
![Entrando nas configurações da metamask](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/niw2diz82a7dc57kgj7v.png)

Clique em "Advanced".
![Entrando nas configurações avançadas](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/d97vijw6jbhpgntds4fb.png)

Desça a página até encontrar a opção "Show test networks" e ative essa opção
![Ativando a visualização de redes de testes](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/p2szwcplokse6jp960ia.png)

Após ativarmos isso vamos conseguir não só ver as redes [Mainnet](https://academy.bit2me.com/pt/o-que-%C3%A9-uma-rede-principal/) mas também as redes [Testnet](https://academy.bit2me.com/pt/que-es-testnet/).
Agora clique em "Ethereum Mainnet" e mude para "Goerli Test Network"
![Mudando a rede na metamask](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/rwww326fuvf88hf0sby3.png)

Para conseguirmos subir nossos contratos para blockchain vamos precisar de dinheiro para pagar o GAS da transação, mas não precisa se preocupar, como estamos usando uma rede de teste tudo lá é de mentira até o dinheiro, para isso existe as torneiras de moeda entre nesse site [Goerli faucet](https://goerlifaucet.com/), copie o endereço da sua carteira.
![Copiando o endereço da carteira](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/r309ryj6jxu0h6ovggyc.png)
E informe o seu endereço e clique em "Send Me ETH".
![Pedindo alguns ETH na rede goerli](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/6m8tfuu7xmtfzccaufod.png)

Agora precisamos pegar uma informação da nossa carteira, vamos clicar nos três pontos e clicar em "Account details".
![Visualizando mais detalhes do nosso endereço](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/9vjf34dmlc3a13dn5t4e.png)

Clique em "Export Private Key".
![Exportando a chave privada do nosso endereço](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/a6yhzhamh7gur8oek4vw.png)
Informe a senha da sua carteira.
![Informando nossa senha](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/ckmxas3wp6noytsipvg0.png)
Após isso, irá carregar a chave da nossa carteira.
**TOME CUIDADO COM ESSA CHAVE, NUNCA ENVIE OU COLOQUE ELA EM NENHUM LUGAR DA INTERNET, COM ESSA CHAVE QUALQUER PESSOA CONSEGUE FAZER TRANSFERÊNCIA DA SUA CARTEIRA SEM PRECISAR DA SUA SENHA.**
![Cópiando a nossa chave privada](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/lio6ojfcuzpej4wpjhod.png)

Dentro do arquivo `.env` vamos informar nossa "PRIVATE_KEY"

```env
STAGING_ALCHEMY_KEY="COLE AQUI SUA CHAVE HTTPS"
PRIVATE_KEY="COLE AQUI SUA PRIVATE KEY"
```

Dentro do arquivo `hardhat.config.js` vamos adicionar algumas informações da nossa networks utilizando as variáveis de ambiente que criamos mais cedo e importar os arquivos do `dotenv`.

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: process.env.STAGING_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
```

No seu terminal na pasta do nosso projeto, vamos executar o seguinte comando:

```bash
npx hardhat run scripts/deploy.js --network goerli
```

Se tudo estiver certo esse comando irá realizar o deploy do nosso contrato para blockchain, e ira retornar o endereço do nosso contrato.
![Endereço do nosso contrato](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/trg4mjb89749yioqhxgx.png)

Copiando esse endereço e entrando no [Goerli Etherscan](https://goerli.etherscan.io/) conseguimos ver o nosso contrato na blockchain.
![Nosso contrato na blockchain](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/64k48v73qdnmf48hi774.png)

> Clique [aqui](https://goerli.etherscan.io/address/0xB5F80522F988E8f43726520F1A7e9D877189003C) para ver o contrato que subimos para blockchain nesse post.

## Conclusão

Esse foi o quinto post da série de posts "Meu primeiro smart contract".
Se tudo deu certo, agora você tem o hardhat configurado na sua máquina para fazer deploy de smart contracts para blockchain e tem o seu primeiro smart contract rodando na testnet Goerli sendo gerenciado pelo Alchemy.

Se você gostou do conteúdo e te ajudou de alguma forma, deixe um like para ajudar o conteúdo a chegar para mais pessoas.

![deixa um like](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7quw5wii7e1aihephclv.gif)

---

### Link do repositório

https://github.com/viniblack/meu-primeiro-smart-contract

### Vamos trocar uma ideia ?

Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/
