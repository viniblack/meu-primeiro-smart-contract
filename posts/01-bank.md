Esse é o segundo post da série **Meu primeiro smart contract**, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.
 
Nesse post vamos criar um contrato básico de um banco, onde você vai conseguir depositar uma quantidade de "dinheiro" e mudar o dono do contrato. 
 
## Ferramentas
Vamos continuar usando [Remix IDE](https://remix.ethereum.org/) para criação dos nossos contratos.
 
## Criando um novo arquivo
Vamos criar um novo arquivo dentro da pasta `contracts` chamado `01-bank.sol`
 
![Criando o novo contrato 01-bank.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/xdhucxp1txjut1k8mlpu.png)
 
Dentro do arquivo `01-bank.sol`, vamos declarar as licenças do nosso contrato, a versão do solidity e dar um nome para o contrato.
 
```solidity
// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.7.0 <0.9.0;
 
contract Bank {
 
}
```
 
## Organização do código
Não existe uma forma certa de estruturar o código dos nossos contratos, mas para facilitar o entendimento vamos utilizar o seguinte padrão:
 
![Estrutura do código](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/07nkjrxgyl3j9pr60kqb.png)
 
1. **Properties**: Onde definimos nossas variáveis;
2. **Modifiers**: Onde definimos nossos modificadores, (nesse post vamos entender para que serve);
3. **Events**: Onde definimos nossos eventos, (nesse post vamos entender como funciona);
4. **Constructor**: Onde definimos nosso construtor;
5. **Public Functions**: Onde definimos nossas funções públicas;
 
## Variáveis
Vamos começar criando uma a variável privada chamada `owner` que vai ser do tipo `address`, e uma variável pública chamada `addressToBalance` que vai ser do tipo `mapping`, essa variável recebe um `address` como chave e armazena um `uint` como valor. 
O `mapping` é usado ​​para armazenar dados na forma de pares **chave-valor**, a chave pode ser qualquer um dos tipos de dados do solidity. `mapping` parece muito com um objeto, onde você pode criar uma chave e definir um valor para ele.
 
```solidity
    //Properties
    address private owner;
    mapping(address => uint) public addressToBalance;
```
> Caso queira entender um pouco mais sobre os tipos de dados que exite no solidity clique [aqui](https://blog.logrocket.com/ultimate-guide-data-types-solidity/)
 
## Modificadores
O `modifier` é usado ​​para modificar o comportamento de uma função.
Por exemplo, vamos criar um `modifier` chamado `isOwner` que dentro dele vai ter um `require`, que basicamente vai exigir que o `msg.sender` (_já vamos ver o que é isso_) seja igual o endereço do dono do contrato (owner).
 
```solidity
    //Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }
```
 
> Na linha {1} estamos utilizando um padrão criado pela comunidade que é colocar um `_;` no final dos `modifier` para demonstrar que é o final do modificador.
 
## Eventos
Agora vamos criar os eventos `BalanceIncreased` passando como
parâmetros `target` que vai ser do tipo `address` e `balance` que vai ser do tipo `uint256`, que vai ser chamado quando depositamos uma quantidade de "dinheiro" para um endereço.
E no `OwnerChanged` vamos passar como parâmetros `oldOwner` que vai ser do tipo `address` e `newOwner` que também vai ser do tipo `address`, que vai ser chamado quando mudarmos o dono do nosso contrato.
Quando um `event` é emitido ele armazena os argumentos passados e realiza uma ação.
Um evento gerado não é acessível dentro dos contratos, nem mesmo aqueles que os criou ou chamou. Os eventos no solidity servem para enviarmos alguma resposta para o nosso front-end, por exemplo depois que acontecer alguma ação no contrato.
 
```solidity
  //Events
    event BalanceIncreased(address target, uint256 balance);
    event OwnerChanged(address oldOwner, address newOwner);
```
 
## Construtor
Vamos agora criar o nosso `constructor`, que vai definir que o `owner` vai receber o `msg.sender`, resumidamente o `msg.sender` é sempre o endereço de quem chamou a função. Nesse caso estamos definindo que quem fez o deploy do contrato vai ser o `owner` do contrato.
> Caso queira entender um pouco mais sobre `msg.sender` clique [aqui](https://solidity.web3dev.com.br/apostila/variaveis-built-in-msg.sender-msg.value...#msg.sender)
```solidity
   //Constructor
    constructor() {
        owner = msg.sender;
    }
```
 
## Funções
### Adicionar saldo à um endereço
Vamos criar uma função pública chamada `addBalance` que vai nos permitir adicionar uma quantia de "dinheiro" há uma conta. Para conseguirmos fazer isso `addBalance` irá ter alguns parâmetros como `to` que vai ser do tipo `address` e `value` que vai ser do tipo `uint`.
 
```solidity
  //Public functions
    function addBalance(address to, uint value) public {
 
    }
```
E por questão de segurança queremos que somente o dono (owner) do contrato possa adicionar "dinheiro" há um endereço. Para isso vamos colocar na frente da nossa função o nosso modificador `isOwner`, assim antes de executar nossa função ele vai executar o nosso modificador `isOwner` e verificar se quem está chamando a função é o `owner`, se não for vai retornar uma mensagem de erro.
```solidity
  //Public functions
     function addBalance(address to, uint value) public isOwner {
 
    }
```
Dentro da nossa função `addBalance` vamos escrever a lógica para adicionar uma quantidade de "dinheiro" há uma conta.
Usando o nosso mapping `addressToBalance` vamos pegar a quantidade de "dinheiro" do endereço do parâmetro `to` e adicionamos uma quantidade de "dinheiro" que vamos passar no parâmetro `value`, depois vamos chamar o evento `BalanceIncreased` passando como parâmetros o endereço (`to`) e a quantidade (`value`) de "dinheiro" que queremos enviar.
 
```solidity
//Public functions
    function addBalance(address to, uint value) public isOwner {
        addressToBalance[address(to)] = addressToBalance[address(to)] + value;
        emit BalanceIncreased(to, value);
    }
```
 
### Alterando dono do contrato
As regras da nossa função para trocar o dono do contrato é bem parecida com a da função `addBalance`.
Vamos criar uma função pública chamada `changeOwner` que somente o dono do contrato (`owner`) vai conseguir chamar essa função, que seja possível passar um endereço (`newOwnerContract`) como parâmetro. 
```solidity
    function changeOwner(address newOwnerContract) public isOwner{
    
    }
```
Dentro da nossa função `changeOwner` vamos redefinir o valor da variável `owner` para o endereço do novo dono (`newOwnerContract`), e chamar  nosso evento `OwnerChanged` passando o endereço do atual dono (`owner`) do contrato e o endereço do novo dono (`newOwnerContract`) como parâmetros. 
 
```solidity
    function changeOwner(address newOwnerContract) public isOwner{
        owner = newOwnerContract;
        emit OwnerChanged(owner, newOwnerContract);
    }
```
 
## Como ficou nosso código
```solidity
// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.7.0 <0.9.0;
 
contract Bank {
    
    //Properties
    address private owner;
    mapping(address => uint) public addressToBalance;
 
    //Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }
 
    //Events
    event BalanceIncreased(address target, uint256 balance);
    event OwnerChanged(address oldOwner, address newOwner);
 
    //Constructor
    constructor() {
        owner = msg.sender;
    }
 
    //Public functions
    function addBalance(address to, uint value) public isOwner {
        addressToBalance[address(to)] = addressToBalance[address(to)] + value;
        emit BalanceIncreased(to, value);
    }
 
    function changeOwner(address newOwnerContract) public isOwner{
        owner = newOwnerContract;
        emit OwnerChanged(owner, newOwnerContract);
    }
}
```
 
## Mão na massa
Agora vamos compilar e realizar o deploy do nosso contrato `01-bank.sol`.
1. No menu lateral esquerdo clique em "Solidity compiler".
![Abrindo aba para compilar o contrato](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/g2imfilnejq6qy2lrknj.png)

2. Clique no botão "Compile 01-bank.sol".
![Compilando o contrato 01-bank.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jijvl1pdqv0qwfv18bsn.png)

3. No menu lateral esquerdo clique em "Deploy & run transactions".
![Abrindo aba para fazer o deploy](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/9zqkkc5lynrlolfanaf1.png)

4. Clique no botão "Deploy".
![Fazendo o deploy do contrato 01-bank.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qjoa8zi2m7v28nkzwp07.png)

5. Clique na seta para vermos as funções do nosso contrato.
![Abrindo contrato que fizemos deploy](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/juc4zxtr7zpjr4fs5xv0.png)

6. Copie o endereço da carteira que fizemos o deploy.
![copiando endereço da carteira](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/tw9fa9d88ji4kuamsb0x.png)

7. Clique em "addressToBalance" para verificar o salto do endereço que passamos.
![Utilizando a função addressToBalance do contrato 01-bank.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4d72nk6zx8b5yblbf83h.png)

8. Podemos ver que o saldo do nosso endereço está zerado.
![Verificando saldo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/a2ik6tp9m06q91w9z3ra.png) 

9. Clique na seta para vermos todos os campos da função.
![Vendo todos os campos da função addBalance](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/1t5w23hbtxy8fvbs6zki.png)

10. Copie o endereço da nossa carteira novamente.
![copiando endereço da nossa carteira](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/v93ydhpcr77ugk9pylzb.png)

11. Informe o endereço da nossa carteira no primeiro campo e informe a quantidade de "dinheiro" que quer depositar.
![Utilizando a função addBalance](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/gmb9ku3pciv4sndlreuh.png)

12. Clique em "addressToBalance" para verificar o salto do endereço após o depósito do "dinheiro".
![Utilizando a função addressToBalance do contrato 01-bank.sol após depósito](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/6z1zq1o08wodo6195k81.png)

13. Podemos ver que o saldo do nosso endereço tem a mesma quantidade de "dinheiro" que passamos na função addBalance.
![Verificando saldo depois de execultar a função addBalance](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/lc8unjoov6ek0xpxe3ji.png)

14. Agora vamos pegar o endereço de outra carteira, para isso só clica em cima do endereço que irá aparecer uma lista de endereços.
![Mudando de endereço](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/f09lmd1a9qk8hon18ta4.png)

15. Copie o endereço dessa nova carteira.
![Copiando endereço da nova carteira](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ofowzltq3484r0i1kfmv.png)

16. Agora vamos voltar para o endereço da primeira carteira, e informe o endereço da carteira que acabamos de copiar e clique na função "changeOwner".
![Utilizando a função changeOwner](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/vg9hffrcgqf1jbrxzviv.png)

17. Se tudo estiver certo quando clicarmos para executar novamente a função "changeOwner" vai dar um erro no console.
![Erro no console](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/t6vnhmw15jbcz0951tvb.png)

## Conclusão
Esse foi o segundo post da série de posts "Meu primeiro smart contract".
Se você realizou todas as etapas acima, agora você tem um smart contract simples de um banco, onde você consegue depositar uma quantia de "dinheiro" e mudar o dono do contrato.

---

### Link do repositório
https://github.com/viniblack/meu-primeiro-smart-contract

### Vamos trocar uma ideia ?
Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/
