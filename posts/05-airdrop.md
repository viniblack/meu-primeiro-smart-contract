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

Para criar um `enum` precisamos declarar o nome e entre chaves os valores que ele pode ter.

```solidity
// Enum
enum Status { PAUSED, ACTIVE, CANCELLED }
```

> Clique [aqui](https://solidity.web3dev.com.br/apostila/12.-enums) para ver mais sobre o enum.

### Variáveis

Para fazer o nosso contrato de airdrop, precisamos criar algumas variaveis.

- `owner`: Que vai ser uma variavel privada do tipo address;
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
  require(contractState == Status.ACTIVE, "The contract is not acvite!");
  _;
}
```

### Eventos

Vamos criar um evento para ser chamado quando "matarmos" o nosso contrato, já vamos ver o que isso significa, para isso vamos passar uma variável do tipo address como parametro.

```solidity
event Killed(address killedBy);
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

### Verifica inscrição

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

Vamos criar uma função pública chamada `changeState` que irá receber um número como parâmetro, esse numero pode ser `0 - PAUSED` `1 - ACTIVE`, só podemos definir status cancelado quando o contrato estiver "morto", essa função só pode ser chamado pelo dono do contrato.

```solidity
function changeState(uint8 status) public isOwner {

}
```

```solidity
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
```
