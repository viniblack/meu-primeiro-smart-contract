Esse é o terceiro post da série **Meu primeiro smart contract**, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.

Nesse post vamos criar um contrato de aposta, onde você vai conseguir escolher um número, apostar uma quantidade de Ether, sortear um número premiado e pagar os vencedores.

## Ferramentas
Vamos continuar usando [Remix IDE](https://remix.ethereum.org/) para criação dos nossos contratos.

## Criando um novo arquivo
Vamos criar um novo arquivo dentro da pasta`contracts` chamado `02-bet.sol`.

![Criando o novo contrato 02-bet.sol](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/6to6pvtga7j1t9t61du6.png)

Dentro do arquivo `02-bet.sol`, vamos declarar as licenças do nosso contrato, a versão do solidity e dar um nome para o contrato.

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bet {

}
```

## Organização do código
Não existe uma forma certa de estruturar o código dos nossos contratos, mas para facilitar o entendimento vamos utilizar o seguinte padrão:

![Estrutura do código](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/uegtekopoij6yeqqftwm.png)

**Structs**: Onde definimos alguns tipos de dados mais complexo (nesse post vamos entender o que isso significa);
**Properties**: Onde definimos nossas variáveis;
**Modifiers**: Onde definimos nossos modificadores;
**Constructor**: Onde definimos nosso construtor;
**Public Functions**: Onde definimos nossas funções públicas;
**Private Functions**: Onde definimos nossas funções privadas;

## Structs
Os `struct` são usados ​​para representar uma estrutura de dados.
Por exemplo, para conseguirmos realizar as nossas apostas todo player precisa informar o **valor apostado** e o **número selecionado**, para isso vamos criar um `struct` chamado `Player` que vai armazenar `amountBet` (valor apostado) e `numberSelected` (número selecionado) e os dois vão ser do tipo `uint256`.

```solidity
//Structs
struct Player{
   uint256 amountBet;
   uint256 numberSelected;
}
```
> Caso queira entender um pouco mais sobre Structs clique [aqui](https://solidity.web3dev.com.br/apostila/11.-struct)

## Variáveis
Para fazermos o nosso sistema de apostas, vamos precisar criar algumas variáveis públicas para armazenar nossos dados.
- `owner`: Que vai ser do tipo `address`;
- `players`: Que vai ser um array do tipo `address`;
- `winners`: Que vai ser um array do tipo `address`;
- `totalBet`: Que vai ser do tipo `uint256`;
- `minimunBet`: Que vai ser do tipo `uint256`;
- `addressToPlayer`: Que vai ser um `mapping` que irá receber `address` como "chave" e `Player` como "valor"; 

```solidity
// Properties
address public owner;
address[] public players;
address[] public winners;
uint256 public totalBet;
uint256 public minimunBet;

mapping(address => Player) addressToPlayer;
```

## Modifiers
Vamos criar o modifier `isOwner` para utilizarmos nas funções que só o dono do contrato poderá executar.

```solidity
modifier isOwner() {
    require(msg.sender == owner , "Sender is not owner!");
    _;
}
```

## Construtor
Vamos agora criar o nosso construtor, que vai definir que o `owner` vai receber o `msg.sender` e vamos fazer uma verificação que o `minimunBetValue` tem que ser diferente de zero, caso `minimunBetValue` for igual a zero vamos retornar uma mensagem de erro.

```solidity
constructor (uint256 minimunBetValue) {
    owner = msg.sender;
    if(minimunBetValue != 0) {
        minimunBet = minimunBetValue;
    }else {
        revert("Invalid value");
    }
}
```
## Funções públicas
### Realizando uma aposta
Vamos criar uma função pública chamada `bet`, onde vamos conseguir passar o parâmetro `numberSelected` que vai ser do tipo `uint256`.
Como essa função irá interagir com Ethers precisamos garantir que esses Ethers sejam enviados para o contrato.
Para que o solidity entenda que ela vai mexer com Ethers precisamos adicionar o modificador `payable`, qualquer função no Solidity com o modificador Payable garante que a função possa enviar e receber Ethers.

```solidity
// Public Functions
function bet(uint256 numberSelected) public payable {
      
}
```
> Caso queria entender um pouco mais sobre o modificador payable clique [aqui](https://solidity.web3dev.com.br/apostila/18.-modificadores) 

Dentro da função `bet` vamos verificar se o valor apostado é maior ou igual ao `minimunBet`, se for maior vamos criar duas variaveis, uma chamada `valueBet` do tipo `uint256` que irá receber o `msg.value` e outra chamada `playerBet` do tipo `address` que irá receber `msg.sender`.

```solidity
// Public Functions
function bet(uint256 numberSelected) public payable {
    require(msg.value >= minimunBet * 10**18, "The bet amount is less than the minimum allowed");
    uint256 valueBet = msg.value;
    address playerBet = msg.sender;
}
```
Agora vamos adicionar as informações dos nossos apostadores na nossa lista `addressToPlayer`.
Vamos criar uma variável chamada `newPlayer`, que vai ser do tipo `Player` e como nossas variáveis não vão gravar nada dentro delas, só vamos usar elas como local temporário para armazenar os dados até salvarmos esses dados dentro de uma variável precisamos informar que ela é um `memory`. Dentro da variável `newPlayer`, vamos definir que `numberSelected` vai receber `numberSelected` e `amountBet` vai receber `valueBet`  ao final disso vamos adicionar o nosso `newPlayer` dentro do mapping `addressToPlayer` com a "chave" `playerBet`.

```solidity
// Public Functions
function bet(uint256 numberSelected) public payable {
    require(msg.value >= minimunBet * 10**18, "The bet amount is less than the minimum allowed");
    uint256 valueBet = msg.value;
    address playerBet = msg.sender;

    Player memory newPlayer = Player({
        numberSelected : numberSelected,
        amountBet: valueBet
    });
    addressToPlayer[playerBet] = newPlayer;
}
```
> Caso queira entender um pouco mais sobre `memory` clique [aqui](https://solidity.web3dev.com.br/apostila/13.-memory-vs-storage).

No final da função vamos somar o valor apostado com o `totalBet` e adicionar `playerBet` no nosso array `players`.

```solidity
// Public Functions
function bet(uint256 numberSelected) public payable {
    require(msg.value >= minimunBet * 10**18, "The bet amount is less than the minimum allowed");
    uint256 valueBet = msg.value;
    address playerBet = msg.sender;

    Player memory newPlayer = Player({
        numberSelected : numberSelected,
        amountBet: valueBet
    });
    addressToPlayer[playerBet] = newPlayer;

    totalBet += valueBet;
    players.push(playerBet);
}
```
### Gerando vencedor
Vamos criar uma função pública chamada `generateWinner`, apenas o dono do contrato vai conseguir utilizar essa função, por isso precisamos chamar nosso modificador `isOwner`, dentro da função`generateWinner`  vamos chamar a função `generateWinnerNumber`.

```solidity
 function generateWinner() public isOwner{
    generateWinnerNumber();
}
```

## Funções privadas
### Pagando vencedor
Vamos criar uma função privada chamada `rewardWinner` onde vamos conseguir passar o parametro `numberPrizeGenerated` que vai ser do tipo `uint256`.

```solidity
// Private Functions
function rewardWinner(uint256 numberPrizeGenerated)  private{

}
```
Dentro da função `rewardWinner`, vamos criar uma variável chamada `count` que vai ser do tipo `uint256` que vai receber 0 inicialmente. E vamos criar uma estrutura de repetição para verificar se algum número apostado é igual ao número sorteado, para isso criaremos uma variável chamada `playerAddress` do tipo `address` que vai receber `players[i]` assim vamos conseguir verificar se o número de todos os apostadores é igual o número sorteado, se for igual vamos adicionar o endereço do apostador no array `winners` e aumentar o `count`.

```solidity
// Private Functions
function rewardWinner(uint256 numberPrizeGenerated)  private{
    uint256 count = 0;
        
    for(uint256 i = 0; i < players.length; i++){
        address playerAddress = players[i]; 
     
        if(addressToPlayer[playerAddress].numberSelected == numberPrizeGenerated){
            winners.push(playerAddress);
            count++;
        }
    }
}
```
> Caso queira entender um pouco mais sobre estruturas de repetição no solidity clique [aqui](https://solidity.web3dev.com.br/apostila/controladores-de-fluxo-if-for-while) 

Agora vamos realizar o pagamento para os vencedores, para isso vamos fazer uma validação para ver se o `count` é diferente de zero, se for diferente vamos criar uma variável chamada `winnerEtherAmount` que vai receber `totalBet` dividido pelo `count` e vamos criar uma estrutura de repetição para fazer o pagamento para todos os vencedores, então vamos criar uma variável chamada `payTo` que vai ser do tipo `address` e `payable` e vai receber `winners[j]`. Vamos fazer uma verificação para ver se o endereço do vencedor é um endereço válido, se for vamos realizar a transferência para esse endereço.
 
```solidity
// Private Functions
function rewardWinner(uint256 numberPrizeGenerated)  private{
    uint256 count = 0;
        
    for(uint256 i = 0; i < players.length; i++){
        address playerAddress = players[i]; 
     
        if(addressToPlayer[playerAddress].numberSelected == numberPrizeGenerated){
            winners.push(playerAddress);
            count++;
        }
    }

    if(count != 0){
        uint256 winnerEtherAmount = totalBet / count;
        for(uint256 j = 0; j < count; j++) {
            address payable payTo = payable(winners[j]);
            if(payTo != address(0)) {
                payTo.transfer(winnerEtherAmount);
            }
        }
    }
}
```
> Caso queira entender o que significa `address(0)` clique [aqui](https://ethereum.stackexchange.com/questions/84346/what-address0-means-more-specific-where-those-token-go#answer-84347)

### Sorteado um número 
Vamos criar uma função privada chamada `generateWinnerNumber` que vai ser responsável por sortear um número aleatório.
Precisamos ter em mente que solidity não é capaz de criar números aleatórios. Na verdade, nenhuma linguagem de programação por si só é capaz de criar números completamente aleatórios.
Mas conseguimos criar números pseudo-aleatórios que são conjuntos de valores ou elementos que são estatisticamente aleatórios, mas é derivado de um ponto de partida conhecido e normalmente é repetido várias vezes.
Então vamos criar uma variável do tipo `uint256` chamada `numberPrize` que vai receber `block.number` que é o número do bloco atual + `block.timestamp` que é o número em segundos da data e hora que o bloco foi fechado, e vamos dividir tudo isso por 10 e pegar o resto dessa divisão e somar com + 1 .
E vamos chamar a função `rewardWinner` passando `numberPrize` como parâmetro.

```solidity
function generateWinnerNumber() private {
    uint256 numberPrize = (block.number + block.timestamp) % 10 + 1;
    rewardWinner(uint256(numberPrize));
}
```
## Como ficou nosso código

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bet {

    //Structs
    struct Player{
        uint256 amountBet;
        uint256 numberSelected;
    }

    // Properties
    address public owner;
    address[] public players;
    uint256 public totalBet;
    uint256 public minimunBet;
    address[] public winners;

    mapping(address => Player) addressToPlayer;
    mapping(address => uint256) private addressToBalance;


    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

    // Constructor
    constructor (uint256 minimunBetValue) {
        owner = msg.sender;
        if(minimunBetValue != 0) {
            minimunBet = minimunBetValue;
        }else {
            revert("Invalid value");
        }
    }

    // Public Functions
    function bet(uint256 numberSelected) public payable {
        require(msg.value >= minimunBet * 10**18, "The bet amount is less than the minimum allowed");
        uint256 valueBet = msg.value;
        address playerBet = msg.sender;

        Player memory newPlayer = Player({
            numberSelected : numberSelected,
            amountBet: valueBet
        });
        addressToPlayer[playerBet] = newPlayer;

        totalBet += valueBet;
        players.push(playerBet);
    }

    // Private Functions
    function rewardWinner(uint256 numberPrizeGenerated) private{
        uint256 count = 0;
        
        for(uint256 i = 0; i < players.length; i++){
            address playerAddress = players[i]; 
     
            if(addressToPlayer[playerAddress].numberSelected == numberPrizeGenerated){
                winners.push(playerAddress);
                count++;
            }
        }

        if(count != 0){
             uint256  winnerEtherAmount = totalBet/count;
            for(uint256 j = 0; j < count; j++) {
                address payable payTo = payable(winners[j]); // verificar se precisa dos dois payable
                if(payTo != address(0)) {
                    payTo.transfer(winnerEtherAmount);
                }
            }
        }
    }

    function generateWinnerNumber() private {
        uint256 numberPrize = (block.number + block.timestamp) % 10 + 1;
        rewardWinner(uint256(numberPrize));
    }

    function generateWinner() public isOwner{
        generateWinnerNumber();
    }
}
```
## Mão na massa
Agora vamos compilar e realizar o deploy do nosso contrato `02-bet.sol`.

1. No menu lateral esquerdo clique em "Solidity compiler".
![Abrindo aba para compilar o contrato](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/bvhg4su48odfaaiujrgy.png)

2. Clique no botão "Compile 02-bet.sol".
![Compilando o contrato 02-bet.sol](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/34p8qbx84uezfiqeh0y2.png)

3. No menu lateral esquerdo clique em "Deploy & run transactions".
![Abrindo aba para fazer o deploy](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/16bdi415jy1dasf2vom6.png)

4. Informe o valor mínimo da aposta e clique no botão "Deploy".
![Fazendo o deploy do contrato 02-bet.sol](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/w3emo8vyutdeajldltel.png)

5. Clique na seta para vermos as funções do nosso contrato.
![Abrindo contrato que fizemos deploy](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/ek5ydghu7fu0k2mtss3s.png)

6. Mude de "Wei" para "Ether".
![Mudando de Wei para Ether](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/i2v7yqsa6zrcbv03xc7v.png)

7. Informe uma quantidade de Ether menor que o valor mínimo da aposta, informe um número para apostar e clique em "bet".
![Realizando uma aposta menor que o valor minimo](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/pckips47hy7poiqra0sv.png)

8. Como fizemos uma aposta com o valor menor que a aposta mínima vai acontecer um erro no console.
![Erro por conta que o valor apostado é menor que o valor da aposta minima](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/aiekmo4u70f2ump2uuc2.png)

9. Agora aposte um valor maior que o valor de aposta mínima, informe um número para apostar e clique em "bet".
![Realizando uma aposta](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/pgph75q8qckc55y2sn0i.png)

10. Troque de carteira.
![Trocando de carteira](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/dg5nxf1998s8s9d31vxo.png)

11. Realize uma aposta com outra carteira.
![Fazendo outra aposta com uma carteira diferente](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/yfe4tdxnm2tenosrd3og.png) 

12. Antes de realizarmos o sorteio do número premiado vamos olhar o saldo das nossas carteiras.
![Vendo saldo das contas antes do sorteio do número premiado](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/jo7odrweumikx6tpuen8.png)

13. Com a carteira de quem fez o deploy do contrato clique no botão "generateWinner"
![Gerando o número premiado](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/589c9vop9aorzkvaiy3b.png)

14. Depois de gerar o número premiado vamos olhar o saldo das nossas carteiras.
![Vendo saldo das contas depois do sorteio do número premiado](https://web3dev-forem-production.s3.amazonaws.com/uploads/articles/3gvlm3knbawplr0sjgwi.png)

## Conclusão
Esse foi o terceiro post da série de posts "Meu primeiro smart contract".
Se você realizou todas as etapas acima, agora você tem um smart contract de aposta, onde você consegue definir o valor mínimo de Ethers para apostar, escolher um número para apostar, apostar uma quantidade de Ether e gerar o número premiado.

---

### Link do repositório
https://github.com/viniblack/meu-primeiro-smart-contract

### Vamos trocar uma ideia ?
Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/