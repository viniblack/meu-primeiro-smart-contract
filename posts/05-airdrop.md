Esse é o sexto post da série Meu primeiro smart contract, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.

Nesse post vamos criar um contrato de airdrop de tokens utilizando o hardhat.

## Ferramentas

Nesse post vamos utilizar o [VS Code](https://code.visualstudio.com/download) para editar o código, o [Node.js](https://nodejs.org/en/download/) para instalar e executar o código.

Vamos continuar usando o mesmo projeto do post anterior, caso você não viu o post anterior clique [aqui](https://www.web3dev.com.br/viniblack/meu-primeiro-smart-contract-subindo-meu-primeiro-smart-contract-para-blockchain-11ij).

## Airdrop

Os airdrops de criptomoedas são uma estratégia de marketing usada por startups para fornecer tokens a traders de criptomoedas existentes gratuitamente ou em troca de um trabalho promocional mínimo.

No VS Code, vamos criar dois novos arquivos dentro da pasta `contracts` um chamado `03-tokens.sol` e outro chamado `05-airdrop.sol`, dentro do `03-tokens.sol` vamos copiar o código que criamos no post [Criando um token ERC-20](https://www.web3dev.com.br/viniblack/meu-primeiro-smart-contract-tokens-erc-20-57cf), caso você não tenho o código clique [aqui](https://github.com/viniblack/meu-primeiro-smart-contract/blob/main/contracts/03-token.sol). E colar dentro de `03-tokens.sol`, e no `05-airdrop.sol` vamos declarar as licenças do nosso contrato, a versão do contrato e dar um nome ao contrato como já fizemos antes, mas agora vamos importar `03-tokens.sol` também.

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./03-token.sol";

contract Airdrop  {

}
```

### Organização do código

Não existe uma forma certa de estruturar o código dos nossos contratos, mas para facilitar o entendimento vamos utilizar o seguinte padrão:

![Estrutura do código](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/fzf4z30wjlzrmp3g2c6w.png)

**Enum**: Onde criamos nossos Enums, que é um tipo de dado utilizado para armazenar um conjunto de valores constantes que não pode ser modificado.
**Properties**: Onde criamos nossas variáveis;
**Modifiers**: Onde criamos nossos modificadores;
**Events**: Onde criamos nossos eventos;
**Constructor**: Onde criamos nosso construtor;
**Public Functions**: Onde criamos nossas funções públicas;
**Private Functions**: Onde criamos nossas funções privadas;

### Enum

Para criar um `enum` precisamos declarar o nome e entre as chaves os valores que ele pode ter.

```solidity
// Enum
enum Status { PAUSED, ACTIVE, CANCELLED }
```

> Clique [aqui](https://solidity.web3dev.com.br/apostila/12.-enums) para ver mais sobre o enum.

### Variáveis

Para fazer o nosso contrato de airdrop, precisamos criar algumas variáveis.

- `owner`: Que vai ser uma variável privada do tipo address;
- `subscribers`: Que vai ser um array de endereços privada do tipo address;
- `tokenAddress`: Que vai ser do tipo address;
- `Status`: Que vai receber `contractState`, quando criarmos o nosso construtor isso vai fazer mais sentido;
- `subscribersMapping`: Que vai ser um mapping que irá receber address como "chave" e bool como "valor";

```solidity
// Properties
address private owner;
address[] private subscribers;
address public tokenAddress;

Status contractState;
mapping(address => bool) subscribersMapping;
```

### Modifiers

Vamos criar alguns modifiers para conseguirmos gerenciar nosso contrato.

O primeiro modifier é o `isOwner`, que vai ser responsável por verificar se o endereço que está tentando acessar o contrato é o dono do contrato.

```solidity
modifier isOwner() {
  require(msg.sender == owner , "Sender is not owner!");
  _;
}
```

O segundo modifier é o `isActived`, que vai ser responsável por verificar se o nosso contrato está ativo.

```solidity
modifier isActived() {
  require(contractState == Status.ACTIVE, "The contract is not active!");
  _;
}
```

### Construtor

Como vamos fazer um contrato de airdrop de token, precisamos passar o endereço do contrato do token como parâmetro, então vamos definir que `tokenAddress` irá receber o parâmetro `token` que é o endereço do contrato do token, e vamos definir que `owner` vai ser o endereço que realizar o deploy do contrato de airdrop e definimos que `contractState` vai iniciar com `Status.PAUSED`.

```solidity
// Constructor
constructor(address token) {
  tokenAddress = token;
  owner = msg.sender;
  contractState = Status.PAUSED;
}
```

### Funções privadas

#### Verifica inscrição

Vamos criar uma função privada chamada `hasSubscribed` que vai verificar se o endereço que está tentando acessar o contrato já está inscrito, para isso irá receber um endereço como parâmetro e irá retornar um `bool`.

```solidity
function hasSubscribed(address subscriber) private view returns(bool) {

}
```

Dentro da função vamos verificar se o endereço que está tentando acessar o contrato já está inscrito, se estiver inscrito vamos retornar uma mensagem de erro, se não estiver inscrito vamos retornar `true`.

```solidity
function hasSubscribed(address subscriber) private view returns(bool) {
  require(subscribersMapping[subscriber] != true, "You already registered");

  return true;
}
```

### Funções públicas

#### Inscrever-se

Vamos criar uma função pública chamada `subscribe`, só podemos chamar `subscribe` caso o contrato esteja ativo, por isso vamos utilizar nosso modifier `isActived` e essa função irá retornar um `bool`.

```solidity
function subscribe() public isActived returns(bool) {

}
```

Dentro da função `subscribe` vamos chamar a função `hasSubscribed` para verificar se o endereço que está tentando acessar o contrato já está inscrito, se não estiver inscrito vamos inscrever esse endereço no array de endereços `subscribers` e vamos adicionar o endereço como chave no mapping `subscribersMapping` e `true` como valor.

```solidity
function subscribe() public isActived returns(bool) {
  hasSubscribed(msg.sender);
  subscribers.push(msg.sender);
  subscribersMapping[msg.sender] = true;
  return true;
}
```

#### Verificando status do contrato

Vamos criar uma função pública chamada `state` que vai retornar o status do contrato.

```solidity
function state() public view returns(Status) {
  return contractState;
}
```

#### Mudando o status do contrato

Vamos criar uma função pública chamada `changeState` que irá receber um número como parâmetro, esse número pode ser `0 - PAUSED` `1 - ACTIVE`, só podemos definir status cancelado quando o contrato estiver "morto", essa função só pode ser chamado pelo dono do contrato.

```solidity
function changeState(uint8 status) public isOwner {

}
```

Agora vamos realizar uma validação para verificar se o status que está tentando definir é válido, se for válido verificamos se o contrato já não está com o status que estamos tentando definir se não estiver mudamos o status do contrato.

```solidity
function changeState(uint8 status) public isOwner {
  require(status <= 1, "Invalid status");

  if(status == 0) {
    require(contractState != Status.PAUSED, "The status is already PAUSED");
    contractState = Status.PAUSED;
  }else {
    require(contractState != Status.ACTIVE, "The status is already ACTIVE");
    contractState = Status.ACTIVE;
  }
}
```

#### Executando o airdrop

Vamos criar uma função pública chamada `execute` que irá retornar um `bool` que só vai poder ser chamada quando o contrato estiver ativo e só o dono do contrato pode executar a função.

```solidity
function execute() public isOwner isActived returns(bool) {

}
```

Dentro da função vamos criar uma variável chamada `balance` que irá receber o saldo de tokens do contrato de airdrop no contrato `CryptoToken`.

```solidity
function execute() public isOwner isActived returns(bool) {
  uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
}
```

A lógica que vamos utilizar para distribuir nossos tokens é pegar o total de tokens e dividir pelo total de endereços que se inscreveram no nosso contrato de airdrop.
Então vamos criar uma variável chamada `amountToTransfer` que irá receber a quantidade total de tokens e dividir pela quantidade total de endereços inscritos no contrato de airdrop.

```solidity
function execute() public isOwner isActived returns(bool) {
  uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
  uint256 amountToTransfer = balance / subscribers.length;
}
```

Para realizarmos o pagamento para todas as pessoas inscritas, vamos criar um looping para percorrer todos os endereços inscritos no contrato de airdrop, vamos verificar se o endereço cadastrado é um endereço válido e depois vamos utilizar o `CryptoToken` passando o endereço do contrato de token e realizar uma transferência passando o endereço da pessoa e a quantidade de tokens que vamos transferir e no final vamos retornar `true`.

```solidity
function execute() public isOwner isActived returns(bool) {
  uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
  uint256 amountToTransfer = balance / subscribers.length;
  for (uint i = 0; i < subscribers.length; i++) {
    require(subscribers[i] != address(0));
    require(CryptoToken(tokenAddress).transfer(subscribers[i], amountToTransfer));
  }

  return true;
}
```

#### Matando o contrato

Como as coisas que são escritas na blockchain não podem ser alteradas após realizarmos o deploy para ela, o solidity criou uma forma de conseguirmos "matar" nosso contrato ele irá continuar na blockchain, mas não será mais possível executar nenhuma função deste contrato.
Para isso, vamos criar uma função pública chamada `kill` que só o dono do contrato poderá executar essa função.

```solidity
function kill() public isOwner {

}
```

Dentro desta função vamos definir que o status do contrato será cancelado e depois vamos chamar uma função chamada `selfdestruct` para matar o contrato passando o endereço do dono do contrato, com isso antes de matar o contrato vamos enviar todos os Ethers para o endereço do dono do contrato caso tiver algum.

```solidity
function kill() public isOwner {
  contractState = Status.CANCELLED;
  selfdestruct(payable(owner));
}
```

> Caso queira entender um pouco mais sobre selfdestruct clique [aqui](https://docs.soliditylang.org/en/v0.8.16/units-and-global-variables.html?highlight=selfdestruct#contract-related)

## Como ficou nosso código

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./03-token.sol";

contract Airdrop  {
  // Enum
  enum Status { PAUSED, ACTIVE, CANCELLED } // mesmo que uint8

  // Properties
  address private owner;
  address[] private subscribers;
  address public tokenAddress;

  Status contractState;
  mapping(address => bool) subscribersMapping;

  // Modifiers
  modifier isOwner() {
    require(msg.sender == owner , "Sender is not owner!");
    _;
  }

  modifier isActived() {
    require(contractState == Status.ACTIVE, "The contract is not active!");
    _;
  }

  // Constructor
  constructor(address token) {
    owner = msg.sender;
    tokenAddress = token;
    contractState = Status.PAUSED;
  }


  // Public Functions
  function subscribe() public isActived returns(bool) {
    hasSubscribed(msg.sender);
    subscribers.push(msg.sender);
    subscribersMapping[msg.sender] = true;
    return true;
  }

  function execute() public isOwner isActived returns(bool) {
    uint256 balance = CryptoToken(tokenAddress).balanceOf(address(this));
    uint256 amountToTransfer = balance / subscribers.length;
    for (uint i = 0; i < subscribers.length; i++) {
      require(subscribers[i] != address(0));
      require(CryptoToken(tokenAddress).transfer(subscribers[i], amountToTransfer));
    }

    return true;
  }

  function state() public view returns(Status) {
    return contractState;
  }

  function changeState(uint8 status) public isOwner {
    require(status <= 1, "Invalid status");

    if(status == 0) {
      require(contractState != Status.PAUSED, "The status is already PAUSED");
      contractState = Status.PAUSED;
    }else if(status == 1){
      require(contractState != Status.ACTIVE, "The status is already ACTIVE");
      contractState = Status.ACTIVE;
    }
  }

  // Private Functions
  function hasSubscribed(address subscriber) private view returns(bool) {
    require(subscribersMapping[subscriber] != true, "You already registered");

    return true;
  }

  function kill() public isOwner {
    contractState = Status.CANCELLED;
    selfdestruct(payable(owner));
  }
}
```

## Deploy

Caso você não tenha visto o post anterior clique [aqui](https://www.web3dev.com.br/viniblack/meu-primeiro-smart-contract-subindo-meu-primeiro-smart-contract-para-blockchain-11ij) onde eu explico com mais detalhes o que é fazer um deploy e como configurar o hardhat para subir nosso contrato para blockchain.
Na pasta `script` vamos criar um arquivo chamado `deploy-airdrop.js` onde vamos escrever nossos códigos para deployar o contrato.

No arquivo `deploy-airdrop.js` vamos importar os arquivos do hardhat e criar nossa função assíncrona `main` e capturar o retorno dos erros caso tenha algum.

```javascript
const hre = require("hardhat");

async function main() {}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Dentro da função `main` vamos nos conectar ao contrato `CryptoToken`, realizar o deploy deste contrato passando mil como parâmetro e escrever no console o endereço do contrato de token.

```javascript
const hre = require("hardhat");

async function main() {
  const CryptoToken = await hre.ethers.getContractFactory("CryptoToken");
  const cryptoToken = await CryptoToken.deploy(1000);
  await cryptoToken.deployed();
  console.log("Endereço do CryptoToken", cryptoToken.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Depois disso vamos se conectar ao contrato `Airdrop`, realizar o deploy passando o endereço do contrato `CryptoToken` como parâmetro e escrever no console o endereço do contrato de airdrop.

```javascript
const hre = require("hardhat");

async function main() {
  const CryptoToken = await hre.ethers.getContractFactory("CryptoToken");
  const cryptoToken = await CryptoToken.deploy(1000);
  await cryptoToken.deployed();
  console.log("Endereço do CryptoToken", cryptoToken.address);

  const Airdrop = await hre.ethers.getContractFactory("Airdrop");
  const airdrop = await Airdrop.deploy(cryptoToken.address);
  await airdrop.deployed();
  console.log("Endereço do Airdrop", airdrop.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Como configuramos o hardhat no post anterior, no terminal vamos executar o seguinte comando:

```bash
npx hardhat run scripts/deploy-airdrop.js --network goerli
```

imagem aqui

Copiando os endereços e entrando no [Goerli Etherscan](https://goerli.etherscan.io/) podemos ver nossos contratos na blockchain da Goerli.
Esses são os contratos que subimos nesse post.
- [CryptoToken](https://goerli.etherscan.io/address/0x075daa13e5181800b918be672e7b9a54af247f99)
- [Airdrop](https://goerli.etherscan.io/address/0x515Dc96919bd7a6dCcdD5d4f8c94AEd65A04BDc0)

## Conclusão

Lorem ipsum.

Se você gostou do conteúdo e te ajudou de alguma forma, deixe um like para ajudar o conteúdo a chegar para mais pessoas.

![deixa um like](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7quw5wii7e1aihephclv.gif)

---

### Link do repositório

https://github.com/viniblack/meu-primeiro-smart-contract

### Vamos trocar uma ideia ?

Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/
