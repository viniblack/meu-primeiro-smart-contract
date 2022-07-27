Esse é o quarto post da série **Meu primeiro smart contract**, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.

Nesse post vamos entender o que são tokens ERC-20 e criar o nosso próprio token ERC-20.

## Ferramentas

Vamos continuar usando [Remix IDE](https://remix.ethereum.org/) para criação dos nossos contratos.dd

## O que são tokens ERC-20?

É uma estrutura padrão para desenvolvimento de tokens, usada na rede Ethereum para facilitar a criação de novas criptomoedas.
Ele é um dos padrões mais utilizados no mundo dos cripto ativos e hoje existem diversos tokens criados a partir dele.

O ERC-20 possuem **6 funções obrigatórias**, algumas **opcionais** e **2 eventos obrigatórios**.

> Caso queira saber mais sobre o ERC-20, clique [aqui](https://coinext.com.br/blog/erc-20)

Nesse post vamos implementar algumas dessas funções e eventos.

## Como criar um token ERC-20?

Igual outras linguagens de programação o solidity possui `interface`, que é um conjunto de rotinas e padrões estabelecidos pelo software para a utilização das suas funcionalidades por aplicativos que não pretendem usar suas funções, mas apenas usá-la como base para criar suas funções.
Existem algumas formas de implementar uma interface no solidity, mas nesse post vamos criar nossa interface dentro do nosso arquivo.

> Caso queira saber mais sobre o interfaces no solidity, clique [aqui](https://solidity.web3dev.com.br/exemplos/linguagem-v0.8.3/interface)

## Criando um novo arquivo

Vamos criar um novo arquivo dentro da pasta `contracts` chamado `03-token.sol`.

![Criando o novo contrato 03-token.sol](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/s7kplpfcf01ilxmujdva.png)

Dentro do arquivo `03-token.sol`, vamos declarar as licenças do nosso contrato, a versão do contrato e dar um nome ao contrato como já fizemos, mas agora vamos declarar nossa interface ERC-20, iremos criar nossa interface com o nome `IERC20` é uma boa prática iniciar nossas interfaces com `I` para sabermos que é uma interface sempre que olharmos.

Dentro do `IERC20`, vamos declarar as funções obrigatórias do contrato e os eventos.

```solidity

interface IERC20 {
  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address to, uint256 quantity) external returns(bool);

  event Transfer(address from, address to, uint256 value);
}
```

- Funções:
- `totalSupply`: Retorna o total de tokens existentes.
  Não precisamos passar nenhum parâmetro para essa função.
- `balanceOf`: Retorna o saldo de um determinado endereço.
  Precisamos passar um parâmetro `address` que é o endereço do usuário que desejamos saber o saldo.
- `transfer`: Realiza a transferência de tokens para um determinado endereço.
  Precisamos passar dois parâmetros: o endereço do usuário que desejamos transferir e o valor da transferência.
- Eventos:
- `Transfer`: Emite um evento quando uma transferência é realizada.
  Precisamos passar três parâmetros: o endereço do usuário que transferiu, o endereço do usuário que recebeu e o valor da transferência.

Para utilizar uma interface em um contrato precisamos colocar `is` na frente do nome do contrato e o nome da interface que queremos utilizar.
Nosso contrato inicialmente vai ficar assim com a interface `IERC20`:

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address to, uint256 quantity) external returns(bool);

  event Transfer(address from, address to, uint256 value);
}

contract CryptoToken is IERC20{

}
```

> Caso queira saber o que são funções external no solidity, clique [aqui](https://solidity.web3dev.com.br/apostila/visibilidade-de-funcoes-external-public-internal-and-private#external)

## Organização do código

Não existe uma forma certa de estruturar o código dos nossos contratos, mas para facilitar o entendimento vamos utilizar o seguinte padrão:

![Estrutura do código](https://i.imgur.com/rpfrcy2.png)

1. **Properties**: Onde definimos nossas variáveis;
2. **Constructor**: Onde definimos nosso construtor;
3. **Public Functions**: Onde definimos nossas funções públicas;

## Variáveis

Vamos começar dando o nome para nosso token, o símbolo dele e quantas casas decimais o token vai ter.

```solidity
//Properties
string public constant name = "CryptoToken";
string public constant symbol = "CRY";
uint8 public constant decimals = 18;
```

Vamos definir nossas variáveis como `constant`, porque variáveis constantes tem seus valores atribuídos em tempo de compilação depois que são compiladas não é possível alterá-los.
Fazemos isso para que não seja possível alterar o nome, símbolo e as casas decimais do nosso token.

Vamos criar uma variável para armazenar o total de tokens existentes e um mapping que vai armazenar a quantidade de tokens para cada endereço.

```solidity
uint256 public totalSupply;

mapping (address => uint256) public addressToBalance;
```

## Construtor

Vamos agora criar o nosso construtor, que vai definir que `totalsupply` vai receber a quantidade total de tokens e que o endereço que fez o deploy vai receber todos esses tokens inicialmente.

```solidity
//Constructor
constructor(uint256 total) {
  totalsupply = total;
  addressToBalance[msg.sender] = totalsupply;
}
```

## Funções públicas

### Total de tokens

Vamos criar uma função pública chamada `totalSupply` que retorna o total de tokens existentes.

```solidity
//Public Functions
function totalSupply() public override view returns(uint256) {
  return totalsupply;
}
```

Precisamos declarar que essa função é `override` porque ela substitui uma classe da interface `IERC20` que foi declarada no início do código.

> Caso queira saber o que são funções override no solidity, clique [aqui](https://www.developer.com/languages/inheritance-solidity/)

### Saldo de um endereço

Para saber o saldo de um determinado endereço, vamos criar uma função pública chamada `balanceOf` que retorna o saldo de um determinado endereço.
Ela espera um parâmetro que é o endereço do usuário que desejamos saber o saldo.

```solidity
function balanceOf(address account) public override view returns(uint256) {
  return addressToBalance[account];
}
```

### Transferência de tokens

Para transferir tokens, vamos criar uma função pública chamada `transfer` que recebe dois parâmetros: o **endereço do usuário** que desejamos transferir e a **quantidade de tokens** que desejamos transferir.

```solidity
function transfer(address to, uint256 quantity) public returns(bool) {
  require(addressToBalance[msg.sender] >= quantity, "Insufficient Balance to Transfer");

  addressToBalance[msg.sender] = addressToBalance[msg.sender] - quantity;
  addressToBalance[to] = addressToBalance[to] + quantity;

  emit Transfer(msg.sender, to, quantity);
  return true;
}
```

### Como ficou nosso código

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
  function totalSupply() external view returns(uint256);
  function balanceOf(address account) external view returns(uint256);
  function transfer(address to, uint256 quantity) external returns(bool);

  event Transfer(address from, address to, uint256 value);
}

contract CryptoToken is IERC20 {

  //Properties
  string public constant name = "CryptoToken";
  string public constant symbol = "CRY";
  uint8 public constant decimals = 7;  //Padrão do Ether é 18
  uint256 private totalsupply;

  mapping(address => uint256) private addressToBalance;

  //Constructor
  constructor(uint256 total) {
    totalsupply = total;
    addressToBalance[msg.sender] = totalsupply;
  }

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
}
```

## Mão na massa

Agora vamos compilar e realizar o deploy do nosso contrato `03-token.sol`.

1. No menu lateral esquerdo clique em "Solidity compiler".
   ![Abrindo aba para compilar o contrato](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/tozq9z3ztbqohcst3yes.png)

2. Clique no botão "Compile 03-token.sol".
   ![Compilando o contrato 03-token.sol](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/mpb58rbq91ojzdrdrrhy.png)

3. No menu lateral esquerdo clique em "Deploy & run transactions".
   ![Abrindo aba para fazer o deploy](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/cqgb101edl6z1r808zel.png)

4. Informe a quantidade inicial de tokens e clique no botão "Deploy".
   ![Fazendo o deploy do contrato 03-token.sol](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/juet2s6pki7ppfy9euox.png)

5. Clique na seta para vermos as funções do nosso contrato.
   ![Abrindo contrato que fizemos deploy](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/abfalgdta9ewyys70eh0.png)

6. Podemos verificar as casas decimais do nosso token, o nome do token, o símbolo e a quantidade total de tokens.
   ![Verificando as informações do token](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/4b9rs8a3np3yzlh6uhhu.png)

7. Copie o endereço da carteira que foi feito o deploy e clique em "balanceOf" para vermos a quantidade de tokens que esse endereço tem.
   ![Verificando a quantidade de tokens de um endereço](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/m9opoly8bi8opukaa961.png)

8. Troque de endereço.
   ![Trocando de endereço](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/pe4v8hh5mpev099vtkjm.png)

9. Copie o endereço dessa carteira e clique em "balanceOf" para vermos a quantidade de tokens que esse endereço tem.
   ![Verificando a quantidade de tokens de um endereço](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/vsg570magik2hsikfztv.png)

10. Volte para o endereço que fez o deploy do contrato, e informe o endereço da carteira que copiamos, a quantidade de tokens que queremos enviar e clique na função "transact".
    ![Transferindo uma quantidade de tokens](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/1rsmbkfqhfoc81hwtk19.png)

11. Verifique a quantidade de tokens novamente do endereço que acabamos de fazer a transferência.
    ![Verificando quantidade de tokens após a transferencia](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/6ocoiasit1xmll7rgaun.png)

## Conclusão

Esse foi o quarto post da série de posts "Meu primeiro smart contract".
Se você realizou todas as etapas acima, agora você tem um contrato de um token ERC-20 que consegue definir o nome do token, o símbolo do token, as casas decimais do token, ver a quantidade total de tokens existentes, consultar o saldo de tokens de um endereço, criar tokens e transferir tokens.

## Referencias

[ERC20 & EIP-20](https://solidity.web3dev.com.br/evm-maquina-virtual-ethereum/patterns-and-standards/erc20-and-eip-20)
[O Que São Tokens ERC-20?](https://www.binance.com/pt-BR/blog/all/o-que-s%C3%A3o-tokens-erc20-421499824684902563)
[ERC-20: O que é e como funciona esse tipo de token?](https://coinext.com.br/blog/erc-20)
[Token Standards](https://ethereum.org/en/developers/docs/standards/tokens/)

---

### Link do repositório

https://github.com/viniblack/meu-primeiro-smart-contract

### Vamos trocar uma ideia ?

Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/
