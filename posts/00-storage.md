Esse é o primeiro post da série **Meu primeiro smart contract**, que tem a intenção de ensinar ao longo de sete semanas alguns conceitos do solidity até construirmos um token baseado no ERC-20 com alguns testes unitários.

Nesse post vamos criar o nosso primeiro smart contract, onde você vai conseguir salvar um número no contrato e consultar esse número.

## Ferramentas
Nesse começo vamos utilizar o [Remix IDE](https://remix.ethereum.org/) para criarmos os nossos primeiros contratos.

## Criando um novo arquivo

Quando abrimos o Remix já vão ter algumas pastas e arquivos criados.
![Arquivos iniciais remix](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/9vdkbmzzgcidxq5nwcun.png)

Por enquanto, vamos ignorar esses arquivos e criar um novo arquivo dentro da pasta `contracts` chamado `00-storage.sol`

![Onde clicar para criar um novo arquivo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/h0kl4krnih31uf2wk9x1.png)

![Informando o nome do novo arquivo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/r5x4m8pka3l75dbanafz.png)

Dentro do arquivo `00-storage.sol` vamos definir as licenças do nosso contrato e sua versão.
A Partir da versão 0.6.8 do *solidity* precisamos definir uma licença para nossos contratos.
> Você pode entender um pouco mais sobre licenças clicando [aqui](https://forum.openzeppelin.com/t/solidity-0-6-8-introduces-spdx-license-identifiers/2859).

```solidity
// SPDX-License-Identifier: GPL-3.0 // {1}

pragma solidity >=0.7.0 <0.9.0; // {2}
```
Na linha {1} vamos definir qual é a licença do nosso contrato.
Na linha {2} vamos definir em qual versão do solidity nosso contrato vai ser desenvolvido.

Para começarmos a criar o nosso contrato precisamos dar um nome para ele, para fazer isso dentro do solidity é da seguinte forma:
`contract Storage {...}`
Dentro das {} é onde vamos definir as regras do contrato.

## Organização do código

Não existe uma forma certa de estruturar o código dos nossos contratos, mas para facilitar o entendimento vamos utilizar o seguinte padrão:

![Estrutura do código](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/gxom2otk8hq1gqvje0w1.png)

1. **Properties**: Onde vamos definir as nossas variáveis;
2. **Constructor**: Onde vamos definir nosso construtor, (nesse post vamos entender para que serve);
3. **Public Functions**: Onde vamos definir nossas funções públicas;

O solidity é uma linguagem fortemente tipada, isso quer dizer que temos que informar qual é o tipo (type) dos nossos objetos e variáveis no momento de sua declaração.
> Caso queira entender um pouco mais sobre tipagem no solidity clique [aqui](https://solidity.web3dev.com.br/apostila/tipos-de-variaveis)

## Variáveis

Vamos começar criando uma variável para armazenar um número inteiro dentro do nosso contrato, para criar uma uma variável no solidity precisamos passar o tipo (type) da variável, definir se ela é pública ou privada e o nome da variável.
Então vamos criar uma variável privada chamada `numeroDev` que vai ser do tipo (type) `int`.

```solidity
contract Storage {
   // Properties
   int private numeroDev;
}
```
Por padrão as variáveis no solidity são públicas, então se você só informar o tipo (type) da variável e seu nome, ela vai ser pública. 

## Construtor

Vamos agora criar o nosso `constructor`, que basicamente é uma função especial usada para inicializar variáveis ​​de estado em um contrato.
O construtor é chamado quando o nosso contrato é criado pela primeira vez e podemos utilizá-los para definir seus valores iniciais.
Então vamos definir que `numeroDev` vai ser igual a 5 inicialmente.

```solidity
    // Constructor
    constructor() {
       numeroDev = 5;
    }
```

## Funções

As funções são blocos de códigos reutilizáveis que podem ser chamadas em qualquer lugar do seu contrato. Isso elimina a necessidade de escrevermos o mesmo código repetidas vezes.
No solidity existe três tipos de funções as funções **puras**, as de **visualização** e as de **modificação**.

**Funções puras**: São funções que não lê ou modifica algum dado da blockchain. Todos os dados com os quais as funções puras estão relacionadas são passadas ​​ou definidas no escopo da função.
Quando temos uma função pura temos que declarar isso, para fazer isso basta colocarmos `pure` na frente do nome da função.

**Funções de visualização**: São funções que servem somente para leitura e não modificam nenhum dado da blockchain.
Quando temos uma função de visualização temos que declarar isso, para fazer isso basta colocarmos `view` na frente do nome da função.

**Funções de modificação**: São funções que servem para mudar algum dado dentro da blockchain.

Igual as variáveis precisamos definir se nossas funções são públicas ou privadas. Se nossa função retornar alguma coisa precisamos informar qual é o tipo (type) desse retorno.
Para fazer isso basta colocarmos `returns (type)` na frente do nome da função.
Vamos criar duas funções:
1. `get()` que vai ser uma função pública do tipo `view` e vai retornar o valor da variável `numeroDev` que é do tipo inteiro.
2. `store` que vai ser uma função pública do modificação, que recebe como parâmetro um número inteiro, e dentro dele vamos fazer a soma de `numeroDev` + `num`.

```solidity
    // Public Functions
    function get() public view returns (int) {
        return numeroDev;
    }

    function store(int num) public {
        numeroDev = numeroDev + num;
    }
```

## Nosso código até agora
Se você você chegou até aqui seu contrato vai estar mais ou menos assim:

```solidity
// SPDX-License-Identifier: GPL-3.0 // {1}

pragma solidity >=0.7.0 <0.9.0; // {2}

contract Storage {

    // Properties
    int private numeroDev;


    // Constructor
    constructor() {
        numeroDev = 5;
     }


    // Public Functions
    function get() public view returns (int) {
        return numeroDev;
    }

    function store(int num) public {
        numeroDev = numeroDev + num;
    }

}
```
## Executando nosso contrato
Agora no **Remix IDE** vamos compilar e realizar o deploy do nosso contrato `00-storage.sol`.

1. No menu lateral esquerdo clique em "Solidity compiler".
![Abrindo aba para compilar o contrato](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/w2mx7stdsexhwejw6k47.png)

2. Clique no botão "Compile 00-storage.sol".
![Compilando o contrato 00-storage.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4uvbl3883eypjym7415o.png)

3. No menu lateral esquerdo clique em "Deploy & run transactions".
![Abrindo aba para fazer o deploy](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/hos0ozikh9erv43lji2y.png)

4. Clique no botão "Deploy".
![Fazendo o deploy do contrato 00-storage.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/e3d4ykdtcl45cfczk6no.png)

5. Clique na seta para vermos as funções do nosso contrato.
![Abrindo contrato que fizemos deploy](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/pfeu7oinfhpvhccd3a3d.png)

6. Clique em "get" para executar a função.
![Utilizando a função get do contrato 00-storage.sol](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/f2ae889or1gz8g6kbw0u.png)

7. Passe um número no input e clique em "store" para executar a função.
![Utilizando a função store do contrato 00-storage.sol para salvar um novo número](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/5lcib9tou0zxu78jgq4u.png)

8. Clique em "get" para executar a função para conferirmos se o valor que passamos foi somado com o valor inicial.
![Utilizando a função get do contrato 00-storage.sol após salvarmos um novo número](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4zlmayo8y0842fwmmvto.png)

## Conclusão
Esse foi o primeiro post da série de posts "Meu primeiro smart contract".
Se você realizou todas as etapas acima, agora você tem um smart contract simples que é possível salvar um dado e consultar esse dado.

---

### Link do repositório
https://github.com/viniblack/meu-primeiro-smart-contract


### Vamos trocar uma ideia ?
Fique a vontade para me chamar para trocarmos uma ideia, aqui embaixo está meu contato.

https://www.linkedin.com/in/viniblack/
