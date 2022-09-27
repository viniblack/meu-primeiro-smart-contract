Esse é o sertimo post da série **Meu primeiro smart contract**, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.

Nesse post vamos terminar de implementar as funções que faltou no [token ERC-20 que criamos](https://www.web3dev.com.br/viniblack/meu-primeiro-smart-contract-tokens-erc-20-57cf).

## Ferramentas

Nesse post vamos utilizar o [VS Code](https://code.visualstudio.com/download) para editar o código, o [Node.js](https://nodejs.org/en/download/) para instalar e executar o código.

Vamos utilizar o mesmo projeto que criamos no post **Subindo meu primeiro smart contract para blockchain**, caso você não tenha visto clique [aqui](https://www.web3dev.com.br/viniblack/meu-primeiro-smart-contract-subindo-meu-primeiro-smart-contract-para-blockchain-11ij), caso você não tenha mais o código você pode pegar [aqui](https://github.com/viniblack/meu-primeiro-smart-contract/blob/main/contracts/03-token.sol).

## CryptoCoin

Nesse post vamos implemantar as funções e eventos que faltaram no token ERC-20 que criamos no post **Criando um token ERC-20**.
Vamos começar adicionando mais alguns metodos na nossa interface, a nossa interface atualmente esta assim:

```solidity
interface IERC20 {
  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address to, uint256 quantity) external returns(bool);

  event Approval(address owner, address spender, uint256 value);
}
```

Vamos adicionar as seguintes funções:

- `allowance`: Retorna o número de tokens que alguem pode transferir em nome de outro endereço.
- `approve`: Define uma quatidade de tokens que pode ser transferida em nome de outro endereço.
- `transferFrom`: Transfere uma quantidade de tokens para outro endereço utilizando o mecanismo de permissão.
- `increaseAllowance`: Aumenta a quantidade de tokens que pode ser transferida em nome de outro endereço.
- `decreaseAllowance`: Diminue a quantidade de tokens que pode ser transferida em nome de outro endereço.

E vamos adicionar mais um evento:

- `Approval`: Emite um evento quando um endereço aprova uma quantidade de tokens para outro endereço.

## Organização do código

Não existe uma forma certa de estruturar o código dos nossos contratos, mas para facilitar o entendimento vamos utilizar o seguinte padrão:

![Estrutura do código](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/jhg1vi1leuyi766hnw03.png)

Enum: Onde criamos nossos Enums, que é um tipo de dado utilizado para armazenar um conjunto de valores constantes que não pode ser modificado.
Properties: Onde criamos nossas variáveis;
Modifiers: Onde criamos nossos modificadores;
Events: Onde criamos nossos eventos;
Constructor: Onde criamos nosso construtor;
Public Functions: Onde criamos nossas funções públicas;

## Enum

Vamos criar um `enum` de status onde vamos definir o estado do nosso contrato.

```solidity
// Enum
enum Status { PAUSED, ACTIVE, CANCELLED }
```

## Variáveis

Vamos criar mais algumas variáveis para armarzenar o endereço do dono do contrato, o estado do contrato, o valor do token e vamos criar dois `mapping` para verificar o saldo de um endereço e um `mapping` que tem outro `mapping` guardamos que endereço tem permissão de transferir uma quantidade de tokens em nome de outro endereço.

```solidity
// Properties
string public constant name = "CryptoCoin";
string public constant symbol = "CRY";
uint8 public constant decimals = 18;
uint256 private totalsupply;

// <-- Adicionado nesse post
address private owner;
Status contractState;
uint256 valorToken;

mapping(address => uint256) private addressToBalance;
mapping(address => mapping (address => uint256)) allowed;
// -->
```

## Modificadores

Vamos criar alguns modificadores para conseguirmos ferenciar nosso contrato.
O primeiro modificador que iremos criar é o `isOwner`, que irá verificar se o endereço que está tentando acessar o contrato é o dono do contrato.

```solidity
// Modifiers
modifier isOwner() {
  require(msg.sender == owner , "Sender is not owner!");
  _;
}
```

O segundo modificador será o `isActive`, que irá verificar se o contrato está ativo.

```solidity
modifier isActive() {
  require(contractState == Status.ACTIVE, "Contract is not Active!");
  _;
}
```

## Eventos

Vamos criar um evento chamado `Mint` que vamos usar mais para frente para ser emitido quando criarmos mais tokens, esse evento vai receber o endereço do dono do contrato, o saldo do endereço do dono, a quantidade de tokens que queremos criar e o total de tokens que já existem no contrato.

```solidity
// Events
event Mint(address owner, uint256 BalanceOwner, uint256 amount, uint256 supply);
```

E vamos criar um evento chamado `Burn` que vamos usar mais para frente também para ser emitido quando 'queimamos' tokens, esse evento vai receber o endereço do dono do contrato, a quandidade de tokens que queremos queimar e total de tokens que já existem no contrato.

```solidity
event Burn(address owner, uint256 value, uint256 supply);
```

## Construtor

No construtor vamos passar o total de tokens como parametro, definir o dono do contrato como quem realizar o deploy, o `totalsupply` recebendo o total e atribuir todos os tokens inicialmente para carteira do dono do contrato e o status inicial do contrato como ativo.

```solidity
// Constructor

constructor(uint256 total) {
  owner = msg.sender;
  totalsupply = total;
  addressToBalance[msg.sender] = totalsupply;
  contractState = Status.ACTIVE;
}
```

Agora vamos adicionar mais algumas funções para conseguirmos gerenciar o status do nosso contrato, criar ou queimar tokens, realizar trânsferencia em nome de um terceiro e matar nosso contrato, os funções do nosso contrato atualmente são essas:

```solidity
//Public Functions
function totalSupply() public override view returns(uint256) {
  return totalsupply;
}

function balanceOf(address account) public override view returns(uint256) {
  return addressToBalance[account];
}

function transfer(address to, uint256 quantity) public override returns(bool) {
  require(addressToBalance[msg.sender] >= quantity, "Insufficient Balance to Transfer");

  addressToBalance[msg.sender] = addressToBalance[msg.sender] - quantity;
  addressToBalance[to] = addressToBalance[to] + quantity;

  emit Transfer(msg.sender, to, quantity);
  return true;
}
```

Vamos implementar as funções que criamos na nossa interface.

## Quantidade restante de tokens

Vamos criar uma função publica chamada `allowance` que retorna o número restante de tokens que um terceiro pode transferir em nome de outro endereço. Ela espera dois parâmetros `from` endereço da carteira que tem permissão de realizar transferência em nome do `spender`.

```solidity
function allowance(address from, address spender) public override view returns (uint) {
  return allowed[from][spender];
}
```

## Permissão de transferência em nome de terceiro

Vamos criar uma função publica chamada `approve` que permite que um terceiro transfera tokens em nome de outro endereço. Ela espera dois parâmetros `spender` endereço de quem eu quero dar permissão de realizar a transferencia e `amount` quantidade de tokens que eu quero dar permissão. Dentro dessa função vamos chamar o evento `allowed` passando a carteira de quem está dando permissão, a carteira de quem está recebendo a permissão e a quantidade de tokens que está sendo permitida.
Após isso vamos emitir o evento `Approval` passando a carteira de quem está dando permissão, a carteira de quem está recebendo a permissão e a quantidade de tokens que está sendo permitida.

```solidity
function approve(address spender, uint256 amount) public override returns (bool) {
  allowed[msg.sender][spender] = amount;

  emit Approval(msg.sender, spender, amount);
  return true;
}
```

## Transferência em nome de terceiro

Vamos criar uma função publica chamada `transferFrom` que irá movimentar tokens de uma carteira para outra. Ela espera três parâmetros `sender` endereço da carteira que tem permissão de realizar transferência em nome do `recipient`, `recipient` endereço da carteira que vai receber os tokens e `amount` quantidade de tokens que vai ser transferida.
Dentro dessa função vamos verificar se o endereço que está tentando realizar a transferência tem permissão para realizar a transferência, se o valor que está sendo transferido é maior que zero e se o endereço que está transferindo tem saldo suficiente para realizar a transferência. Após isso vamos emitir o evento `Transfer` passando a carteira de quem está realizando a transferência, a carteira de quem está recebendo a transferência e a quantidade de tokens que está sendo transferida.

```solidity
function transferFrom(address sender, address recipient, uint256 amount)public isActive override returns(bool) {
  require(amount > 0, "Tranfer value invalid is not zero.");
  require(amount <= balanceOf(sender), "Insufficient Balance to Transfer");
  require(amount <= allowed[sender][msg.sender], "No allowed");

  addressToBalance[sender] -= amount;
  allowed[sender][msg.sender] -= amount;
  addressToBalance[recipient] += amount;

  emit Transfer(sender, recipient, amount);
  return true;
}
```

## Aumentar permissão de transferência em nome de terceiro

Vamos criar uma função publica chamada `increaseAllowance` que irá aumentar a permissão de transferência em nome de terceiro. Ela espera dois parâmetros `spender` endereço da carteira que vai receber a permissão e `addedValue` quantidade de tokens que vai ser adicionada a permissão.
Dentro dessa função vamos verificar se o endereço que está tentando receber a permissão é um endereço valido. Após isso vamos aumentar a permissão de transferência e emitir o evento `Approval` passando a carteira de quem está chamando a função, a carteira de quem está recebendo a permissão e a quantidade de tokens que aprovadas.

```solidity
function increaseAllowance(address spender, uint256 addedValue) public override returns (bool){
  require(spender != address(0), "Invalid address!");

  allowed[msg.sender][spender] += addedValue;

  emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
  return true;
}
```

## Diminuir permissão de transferência em nome de terceiro

Vamos criar uma função publica chamada `decreaseAllowance` que irá diminuir a permissão de transferência em nome de terceiro. Ela espera dois parâmetros `spender` endereço da carteira que vai receber a permissão e `subtractedValue` quantidade de tokens que vai ser removida da permissão.
Dentro dessa função vamos verificar se o endereço que está tentando receber a permissão é um endereço valido. Após isso vamos diminuir a permissão de transferência e emitir o evento `Approval` passando a carteira de quem está chamando a função, a carteira de quem está recebendo a permissão e a quantidade de tokens que aprovadas.

```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
  require(spender != address(0), "Invalid address!");

  allowed[msg.sender][spender] -= subtractedValue;

  emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
  return true;
}
```

## Estado do contrato

Vamos criar uma função publica chamada `state` que irá retornar o estado do contrato. Ela não espera nehum parâmetro e retorna o valor de `contractState`.

```solidity
function state() public view returns(Status) {
  return contractState;
}
```

## Mudar o estado do contrato

Vamos cria uma função chamada `setState` que irá mudar o estado do contrato. Ela espera um parâmetro `status` que é o novo estado do contrato, como `contractState` é um enum então devemos passar um númerico de 0 a 2. Essa função só pode ser chamada pelo dono do contrato, por isso vamos passar o nosso modificado `ìsOwner` que verifica se o endereço que está chamando a função é o dono do contrato.
Dentro dessa função vamos verificar se o novo estado do contrato é diferente do estado atual do contrato, se o novo estado do contrato é um estado válido. Após isso vamos redefinir o valor de `contractState` para o estado passado como parâmetro.

```solidity
function setState(uint8 status) public isOwner {
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

## Cunhando mais tokens

Vamos criar uma função publica chamada `mint` que irá cunhar mais tokens. Ela espera um parâmetro `amount` que é a quantidade de tokens que vai ser cunhada. Essa função só pode ser chamada pelo dono do contrato, por isso vamos passar o nosso modificado `ìsOwner` que verifica se o endereço que está chamando a função é o dono do contrato.
Dentro dessa função vamos verificar se a quantidade de tokens que vai ser cunhada é maior que zero, se for maior que zero vamos aumentar o total de tokens em circulação e aumentar a quantidade de tokens do dono do contrato. Após isso vamos emitir o evento `Mint` passando o endereço do dono do contrato, o salto da carteira do dono do contrato e a quantidade de tokens existentes.

```solidity
function mint(uint256 amount) public isActive isOwner {
  require(amount > 0, "Invalid mint value.");

  totalsupply += amount;
  addressToBalance[owner] += amount;

  emit Mint(owner,addressToBalance[owner], amount, totalSupply());
}
```

## Queimando tokens

Vamos criar uma função publica chamada `burn` que irá queimar tokens. Ela espera um parâmetro `amount` que é a quantidade de tokens que vai ser queimada. Essa função só pode ser chamada pelo dono do contrato, por isso vamos passar o nosso modificado `ìsOwner` que verifica se o endereço que está chamando a função é o dono do contrato.
Dentro dessa função vamos verificar se a quantidade de tokens que vai ser queimada é maior que zero, se for maior que zero vamos verificar se a quantidade de tokens que vai ser queimada é menor ou igual a quantidade de tokens em circulação, se for menor ou igual vamos verificar se a quantidade de tokens que vai ser queimada é menor ou igual a quantidade de tokens do dono do contrato. Após isso vamos diminuir o total de tokens em circulação e diminuir a quantidade de tokens do dono do contrato. Após isso vamos emitir o evento `Burn` passando o endereço do dono do contrato, a quantidade de tokens queimados e a quantidade de tokens existentes.

```solidity
function burn(uint256 amount) public isActive isOwner {
  require(amount > 0, "Invalid burn value.");
  require(totalSupply() >= amount, "The amount exceeds your balance.");
  require(balanceOf(owner) >= amount, "The value exceeds the owner's available amount");

  totalsupply -= amount;
  addressToBalance[owner] -= amount;

  emit Burn(owner, amount, totalSupply());
}
```

## Matando o contrato

Vamos criar uma função publica chamada `kill` que irá matar o contrato. Essa função só pode ser chamada pelo dono do contrato, por isso vamos passar o nosso modificado `ìsOwner` que verifica se o endereço que está chamando a função é o dono do contrato.
Dentro dessa função vamos mudar o estado do contrato para `CANCELLED` e vamos destruir o contrato e enviar todos os Ether do contrato para o dono do contrato.

```solidity
function kill() public isOwner {
  contractState = Status.CANCELLED;
  selfdestruct(payable(owner));
}
```

## Como ficou nosso código

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {

  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address recipient, uint256 amount) external returns(bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function increaseAllowance(address spender, uint256 addedValue) external  returns (bool) ;
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) ;

  event Transfer(address from, address to, uint256 value);
  event Approval(address owner, address spender, uint256 value);

}

contract CryptoCoin is IERC20 {
  // Enum
  enum Status { PAUSED, ACTIVE, CANCELLED }

  //Properties
  address private owner;
  string public constant name = "CryptoCoin";
  string public constant symbol = "CRY";
  uint8 public constant decimals = 18;
  uint256 private totalsupply;
  Status contractState;
  uint256 valorToken;
  mapping(address => mapping (address => uint256)) allowed;
  mapping(address => uint256) private addressToBalance;

  // Modifiers
  modifier isOwner() {
    require(msg.sender == owner , "Sender is not owner!");
    _;
  }

  modifier isActive() {
    require(contractState == Status.ACTIVE, "Contract is not Active!");
    _;
  }

  // Events
  event Mint(address owner, uint256 BalanceOwner, uint256 amount, uint256 supply);
  event Burn(address owner, uint256 value, uint256 supply);


  //Constructor
  constructor(uint256 total) {
    owner = msg.sender;
    totalsupply = total;
    addressToBalance[msg.sender] = totalsupply;
    contractState = Status.ACTIVE;
  }

  //Public Functions
  function totalSupply() public override view returns(uint256) {
    return totalsupply;
  }

  function balanceOf(address tokenOwner) public override view returns(uint256) {
    return addressToBalance[tokenOwner];
  }

  function transfer(address recipient, uint256 amount) public isActive override returns(bool) {
    require(amount <= addressToBalance[msg.sender], "Insufficient Balance to Transfer");

    addressToBalance[msg.sender] -= amount;
    addressToBalance[recipient] += amount;

    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address from, address spender) public override view returns (uint) {
    return allowed[from][spender];
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    allowed[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount)public isActive override returns(bool) {
    require(amount > 0, "Tranfer value invalid is not zero.");
    require(amount <= balanceOf(sender), "Insufficient Balance to Transfer");
    require(amount <= allowed[sender][msg.sender], "No allowed");

    addressToBalance[sender] -= amount;
    allowed[sender][msg.sender] -= amount;
    addressToBalance[recipient] += amount;

    emit Transfer(sender, recipient, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public override returns (bool){
    require(spender != address(0), "Invalid address!");

    allowed[msg.sender][spender] += addedValue;

    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
    require(spender != address(0), "Invalid address!");

    allowed[msg.sender][spender] -= subtractedValue;

    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function state() public view returns(Status) {
    return contractState;
  }

  function setState(uint8 status) public isOwner {
    require(status <= 1, "Invalid status");

    if(status == 0) {
      require(contractState != Status.PAUSED, "The status is already PAUSED");
      contractState = Status.PAUSED;
    }else if(status == 1){
      require(contractState != Status.ACTIVE, "The status is already ACTIVE");
      contractState = Status.ACTIVE;
    }
  }

  function mint(uint256 amount) public isActive isOwner {
    require(amount > 0, "Invalid mint value.");

    totalsupply += amount;
    addressToBalance[owner] += amount;

    emit Mint(owner,addressToBalance[owner], amount, totalSupply());
  }

  function burn(uint256 amount) public isActive isOwner {
    require(amount > 0, "Invalid burn value.");
    require(totalSupply() >= amount, "The amount exceeds your balance.");
    require(balanceOf(owner) >= amount, "The value exceeds the owner's available amount");

    totalsupply -= amount;
    addressToBalance[owner] -= amount;

    emit Burn(owner, amount, totalSupply());
  }

  // Kill
  function kill() public isOwner {
    contractState = Status.CANCELLED;
    selfdestruct(payable(owner));
  }
}

```

## Deploy

Caso você queira entender com mais detalhes de como realizar o deploy de um smart contract clique [aqui](https://www.web3dev.com.br/viniblack/meu-primeiro-smart-contract-subindo-meu-primeiro-smart-contract-para-blockchain-11ij).
Na pasta `script` vamos criar um arquivo chamado `deploy-cryptoCoin.js` onde vamos escrever nossos códigos para deployar o contrato.

No arquivo `deploy-cryptoCoin.js` vamos importar os arquivos do hardhat e criar nossa função assíncrona `main` e capturar o retorno dos erros caso tenha algum.

```javascript
const hre = require("hardhat");

async function main() {}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Dentro da função `main` vamos nos conectar ao contrato CryptoCoin, realizar o deploy deste contrato criando mil tokens e escrever no console o endereço do contrato de token.

```javascript
const hre = require("hardhat");

async function main() {
  const CryptoCoin = await hre.ethers.getContractFactory("CryptoCoin");
  const cryptoCoin = await CryptoCoin.deploy(1000);
  await cryptoCoin.deployed();
  console.log("Endereço do CryptoCoin", cryptoCoin.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Como configuramos o hardhat no post anterior, no terminal vamos executar o seguinte comando:

```bash

npx hardhat run scripts/deploy-cryptoCoin.js --network goerli
```

Se tudo estiver certo esse irá retornar o endereço do nosso contrato.

Copiando os endereços e entrando no [Goerli Etherscan](https://goerli.etherscan.io/) podemos ver nossos contratos na blockchain da Goerli.
Esses são os contratos que subimos nesse post.

- [CryptoCoin](https://goerli.etherscan.io/address/0x751b55B9513e98F56DF71E7A0d70135893Ad56aF)

## Conclusão

Esse foi o setimo post da série "Meu primeiro smart contract".

![deixa um like](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7quw5wii7e1aihephclv.gif)

---

### Link do repositório

https://github.com/viniblack/meu-primeiro-smart-contract

### Vamos trocar uma ideia ?

Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/
