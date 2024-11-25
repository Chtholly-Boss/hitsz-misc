#import "@preview/finite:0.3.2": *

= 实验总体流程与函数功能描述
#show raw: it => {
  if it.block {
    align(center)[
      #block(
        fill: luma(240),
        radius: 5pt, 
        outset: 5pt,
        )[#it] 
    ]
  } else {
    it
  }
}

==	词法分析
===	编码表
词法分析器的目标是识别出输入的字符串中的单词，并按照预定义的规则将它们分类为不同的词法单元。本实验中，我们定义了以下词法单元：
- 关键字：如 `int` 等
- 标识符：由字母、数字和下划线组成的字符串

编码表如下：
#align(center)[
#table(columns: 3,
  [Name], [Type], [Value], 
  [int], [1], [-], 
  [return], [2], [-], 
  [=], [3], [-], 
  [Semicolon], [4], [-], 
  [+], [5], [-], 
  [-], [6], [-], 
  [\*], [7], [-], 
  [/], [8], [-], 
  [(], [9], [-], 
  [)], [10], [-], 
  [id], [51], [String Literal], 
  [IntConst], [52], [Integer Literal], 
)
]

该编码表根据输入文件 `coding_map.csv` 得到。

===	正则文法
本部分的词法通过正则文法进行描述，大致如下：
```regex
Definition:
  G = (V, T, P, S)
  V = {S, A, B, C, Digit, NonZeroDigit, Letter}
  T = {=, ;, +, -, *, /, (, ), [a-zA-Z], 0-9, _}
  P = {
    Letter ::= [a-zA-Z] | _
    Digit ::= [0-9]
    NonZeroDigit ::= [1-9]

    S ::= Letter A 
    A ::= Letter A | Digit A | ε

    S ::= B 
    B ::= = | + | - | * | / | ( | ) | ;

    S ::= C
    C ::= Digit | NonZeroDigit C | ε
  }
```

===	状态转换图
本实验需要根据正则文法构造状态转换图，粗略来讲，需要接受的串类型由下表给出：
#align(center)[
#table(columns: 2,
  [Name], [String], 
  [int], [int], 
  [return], [return],
  [=], [=],
  [Semicolon], [;],
  [+], [+],
  [-], [-],
  [\*], [\*],
  [/], [/],
  [(], [(],
  [)], [)],
  [id], [\[a-zA-Z\_\]\[a-zA-Z0-9\_\]\*],
  [IntConst], [\[1-9\]\*\[0-9\]],
)
]

为简化编码，将运算符和分号作为单字符符号处理，统一为一个状态，用一个子过程处理即可，对于于标识符和整型常量，则分别用两个子过程处理。

另外，对空白符单独处理，跳过即可。

简化后的状态转换图如下：
#figure(
  image("./assets/state.drawio.png", width: 60%)
)

使用该状态图进行词法分析可以得到比原先更简洁的代码，但存在词与词之间可以无间隔的情形，可能造成词法分析错误。

这个问题可以在子过程中通过判断下一个字符是否为空白符来解决，然而，本实验不存在语法错误的程序输入，故该步骤可以省略。

=== 词法分析程序设计思路和算法描述
首先实现一个符号表数据结构，用于存储词法单元。
```java
public class SymbolTable {
    private Map<String, SymbolTableEntry> table = new HashMap<>();

    public SymbolTableEntry get(String text) {
        if (this.has(text)) {
            return table.get(text);
        } else {
            throw new RuntimeException("Couldn't find " + text);
        }
    }

    public SymbolTableEntry add(String text) {
        if (!this.has(text)) {
            return table.put(text,new SymbolTableEntry(text));
        } else {
            throw new RuntimeException("Symbol " + text + "already exists!");
        }
    }

    public boolean has(String text) {
        return this.table.containsKey(text);
    }

    private Map<String, SymbolTableEntry> getAllEntries() {
        return this.table;
    }
    ...
}
```

然后，根据状态转换图，实现词法分析器。
```java
public class LexicalAnalyzer {
    private final SymbolTable symbolTable;
    private enum STATE {
        SPACE, SINGLE, INT_CONST, WORD,
        ERR
    }
    ... // Fields
    public void loadFile(String path) {
        // TODO: 词法分析前的缓冲区实现
        this.src = FileUtils.readFile(path); // 直接读入文件
    }

    public void run() {
        // TODO: 自动机实现的词法分析过程
        STATE s = STATE.ERR;
        while(!isAtEnd()){
            char c = peek();
            if (isSingleSymbol(c)) s = STATE.SINGLE;  // 将运算符和分号作为单字符符号处理
            if (isAlpha(c)) s = STATE.WORD;
            if (isDigit(c)) s = STATE.INT_CONST;
            if (isSpace(c)) s = STATE.SPACE;
            switch (s) { // 根据状态进行相应的处理
                case SPACE -> lexSpace();
                case SINGLE-> lexSingle();
                case INT_CONST -> lexIntConst();
                case WORD -> lexWord();
                case ERR -> System.out.println("Invalid Token");
            }
        }
        // append a EOF
        tokens.add(Token.eof());
    }

    public Iterable<Token> getTokens() {
        // TODO: 从词法分析过程中获取 Token 列表
        System.out.println(tokens);
        return this.tokens;
    }

    public void dumpTokens(String path) {
        FileUtils.writeLines(
            path,
            StreamSupport.stream(getTokens().spliterator(), false).map(Token::toString).toList()
        );
    }
}
```

各状态相应的处理函数如下：
```java

    private void lexSpace(){
        pCur++;
    }
    private void lexSingle(){
        char c = peek();
        switch (c) {
            case ';' -> tokens.add(Token.simple("Semicolon"));
            default -> tokens.add(Token.simple(String.valueOf(c)));
        }
        pCur++;
    }
    private void lexIntConst(){
        int start = pCur;
        while(!isAtEnd() && isDigit(src.charAt(pCur))) pCur++;
        tokens.add(Token.normal("IntConst",src.substring(start,pCur)));
    }
    private void lexWord(){
       int start = pCur;
       advance();
       while(!isAtEnd() && isAlphaNumeric(src.charAt(pCur))) pCur++;
       String token = src.substring(start,pCur);
       if(TokenKind.isAllowed(token)) {
           // a keyword
           tokens.add(Token.simple(token));
       } else {
           // a identifier, add to symbol table
           tokens.add(Token.normal("id", token));
           if (!symbolTable.has(token)) symbolTable.add(token);
       }
    }
```

定义辅助函数以提高代码可读性：
```java
    private boolean isAtEnd(){
        return this.pCur >= this.src.length();
    }
    private boolean isSingleSymbol(char c){
        return
                c == ','
                || c == ';'
                || c == '='
                || c == '+'
                || c == '-'
                || c == '*'
                || c == '/'
                || c == '('
                || c == ')';
    }
    private boolean isSpace(char c){
        return
                c == ' '
                || c == '\t'
                || c == '\n';
    }
    private boolean isDigit(char c) {
        return c >= '0' && c <= '9';
    }
    private boolean isAlpha(char c) {
        return (c >= 'a' && c <= 'z') ||
                (c >= 'A' && c <= 'Z') ||
                c == '_';
    }
    private boolean isAlphaNumeric(char c) {
        return isAlpha(c) || isDigit(c);
    }

    private void advance() {
        if(!isAtEnd()) pCur++;
    }
    private char peek(){
        if (isAtEnd()) return '\0';
        return src.charAt(this.pCur);
    }
```

== 语法分析
本实验采用LR(1)分析法，主要过程如下：
- 拓展文法
- 构造LR(1)分析表
- 根据LR(1)分析表进行语法分析

下面对各个步骤的具体内容进行详细描述：

===	拓展文法
对于某些文法，存在右部含有文法开始符号的产生式，可能导致在归约过程中错误地归约到起始符号导致提前终止。因此，我们需要对原有的文法进行拓展。

本实验中已提供了拓展后的文法 grammer.txt。

===	LR1分析表
根据已有的拓展文法，可以通过计算LR(1)项目集族来构造LR(1)分析表。本实验中已通过利用 *编译工作台* 程序对该过程进行了自动化，并生成了 LR1分析表 LR1_table.csv 供使用。

===	状态栈和符号栈的数据结构和设计思路
为利用LR(1)分析表进行语法分析，我们需要维护两个栈：状态栈和符号栈。其中，状态栈用于存储当前状态，符号栈用于存储已读入的符号。

由于框架已实现了 Status 类，故状态栈可直接定义如下：
```java
    private final Stack<Status> statusStack = new Stack<>();
```

对于符号栈，由于存在终结符和非终结符两种不同的类型，我们通过通过实现一个*容器*类 Symbol 来存储符号。
```java
public class Symbol {
    Token token;
    NonTerminal nonTerminal;
    SourceCodeType type = null;
    IRValue value = null;

    private Symbol(Token token, NonTerminal nonTerminal){
        this.token = token;
        this.nonTerminal = nonTerminal;
    }

    public Symbol(Token token){
        this(token, null);
    }

    public Symbol(NonTerminal nonTerminal){
        this(null, nonTerminal);
    }

    public boolean isToken(){
        return this.token != null;
    }

    public boolean isNonterminal(){
        return this.nonTerminal != null;
    }

    // setters and getters
    ...
}

```

而后，符号栈可定义如下：
```java
    private final Stack<Symbol> symbolStack = new Stack<>();
```

===  LR驱动程序设计思路和算法描述
LR驱动程序即对LR(1)分析过程的具体实现，主要包括以下步骤：
- 读取输入的Token及分析表
- 初始化状态栈和符号栈
- 根据LR(1)分析表进行语法分析
- 输出产生式序列

各部分具体实现如下：

- 读取输入的Token及分析表：

```java
    public void loadTokens(Iterable<Token> tokens) {
        // TODO: 加载词法单元
        tokens.forEach(t -> this.tokenList.add(t)); // 内部使用 List 存储词法单元
    }

    public void loadLRTable(LRTable table) {
        // TODO: 加载 LR 分析表
        this.lrTable = table;
    }
```

- 框架的 run 方法：
```java
    public void run() {
        // TODO: 实现驱动程序
        // 初始化状态栈和符号栈
        this.statusStack.push(this.lrTable.getInit());
        this.symbolStack.push(new Symbol(Token.eof()));
        boolean shouldCont = true; // 是否继续分析
        while (shouldCont) {
          // 获取当前状态和当前词法单元，以及根据LR(1)分析表获取动作
            Token curToken = this.tokenList.get(this.pToken);
            Status curStatus = this.statusStack.peek();
            Action curAction = lrTable.getAction(curStatus, curToken);
            // 根据动作类型进行相应操作
            switch (curAction.getKind()) {
                case Shift -> { // 移入动作
                    callWhenInShift(curStatus, curToken);
                    statusStack.push(curAction.getStatus()); // 将动作对应的状态压入状态栈
                    symbolStack.push(new Symbol(curToken)); // 将当前词法单元压入符号栈
                    this.pToken++;
                }
                case Reduce -> { // 归约动作
                    Production rule = curAction.getProduction();
                    callWhenInReduce(curStatus,rule);
                    // Pop |right| symbols
                    for (int j = 0; j < rule.body().size(); j++) {
                        statusStack.pop();
                        symbolStack.pop();
                    }
                    // Goto
                    statusStack.push(
                      lrTable.getGoto(statusStack.peek(),rule.head())
                      );
                    symbolStack.push(new Symbol(rule.head()));

                }
                case Error -> { // 错误动作
                    shouldCont = false;
                    // panic error now
                    throw new RuntimeException("Error during parsing!!!");
                }
                case Accept -> { // 接收动作
                    shouldCont = false;
                    callWhenInAccept(curStatus);
                }
                default -> {
                    shouldCont = false;
                }
            }
        }
    }
```
上述代码是 Self-Documented Code，通过注释详细说明了各部分的功能和实现方式，此处不再赘述。

== 语义分析和中间代码生成
===	翻译方案
由于我们的语法分析器是基于LR(1)分析表的自底向上分析器，因此我们考虑采用 S-属性 定义的自底向上翻译方案。
具体的翻译方案如下：

```java
Definition:
    P      ::= S_list              -> P.val = S_list.val
    S_list ::= S Semicolon S_list  -> S_list.val = S_list_1.val
    S_list ::= S Semicolon         -> S_list.val = S.val

    S      ::= D id -> {
        p = loopup(id.name)
        if p != None:
            enter(id.name, type D) # enter the id into symbol table
        else:
            error
    }

    S      ::= return E;           -> S.val = E.val
    D      ::= int                 -> D.type = int 
    S      ::= id = E              -> gencode(id.val = E.val)
    E      ::= A                   -> E.val = A.val
    A      ::= B                   -> A.val = B.val
    B      ::= IntConst B.val = IntConst.lexval

    E      ::= E1 + A ->  {
        E.val = new Temp
        gencode(E.val = E1.val + A.val)
    }

    E      ::= E1 - A ->  {
        E.val = new Temp
        gencode(E.val = E1.val - A.val)
    }

    A      ::= A1 * B ->  {
        A.val = new Temp
        gencode(A.val = A1.val * B.val)
    }

    B      ::= ( E )               -> B.val = E.val

    B      ::= id     -> {
        p = loopup(id.name)
        if p != None:
            B.val = p.val
        else:
            error
    }

Note:
    gencode: generate code
    loopup : lookup the symbol in symbol table
    enter  : enter the symbol into symbol table
```

===	语义分析和中间代码生成的数据结构

涉及到的数据结构包括：
- 语法分析类 SynatxAnalyzer
- 符号表类 SymbolTable
- IRValue、IRVariable、IRImmediate 类
- Instruction 类:中间表示的指令
- Production 类:产生式
- Term、NonTerminal、TokenKind、Symbol 类等各类文法符号
- 语义分析栈

===	语义分析程序设计思路和算法描述

由于语义分析器和中间代码生成器已注册到观察者列表中，因此只需要实现对应的 `whenAccept`, `whenShift`, `whenReduce` 方法即可。

根据翻译方案对所有产生式进行分类处理即可，下面同时展示 `SemanticAnalyzer` 和 `IRGenerator` 的代码：
#let compCode(a, b, caption) = figure(
   grid(
        columns: 2, gutter: 1em, 
        align: bottom, 
        figure(
            a, 
            numbering: none, 
            caption: "SemanticAnalyzer"
        ),
        figure(
            b,
            numbering: none,
            caption: "IRGenerator"
        )
   ), caption: caption
)

#compCode(
    [
        ```java
        public void whenAccept() {
            // do nothing
        }
        ```
    ],
    [
        ```java
        public void whenAccept() {
            // do nothing
        }
        ```
    ], 
    "whenAccept"
)

对于 Shift 操作，两部分的处理方式也十分类似：
#figure(
    [
        ```java
        @Override
        public void whenShift(Status currentStatus, Token currentToken) {
            // TODO: 该过程在遇到 shift 时要采取的代码动作
            Symbol curSymbol = new Symbol(currentToken);
            if (currentToken.getKindId().equals("int")) {
                curSymbol.setType(SourceCodeType.Int);
            }
            s.push(curSymbol);
        }
        ```
    ], caption: "SemanticAnalyzer", numbering: none
)

#figure(
    [
        ```java
            @Override
            public void whenShift(Status currentStatus, Token currentToken) {
                // TODO
                String immediate = "^[1-9][0-9]*$";
                Symbol curSymbol = new Symbol(currentToken);
                if (currentToken.getText().matches(immediate)){
                    curSymbol.setValue(
                        IRImmediate.of(Integer.parseInt(currentToken.getText())));
                } else {
                    curSymbol.setValue(IRVariable.named(currentToken.getText()));
                }
                s.push(curSymbol);
            }
        ```
    ], caption: "IRGenerator", numbering: none
)

核心部分在于对每一条产生式的处理，该部分分散在两个类中，但本质上是对翻译方案的直接实现：
#figure(
    [
        ```java
    public void whenReduce(Status currentStatus, Production production) {
        switch (production.index()){
            case 4 -> { // S -> D id
                this.table.get(s.pop().getToken().getText())
                        .setType(s.pop().getType());
                s.push(new Symbol(production.head()));
            }
            case 5 -> { // D -> int
                Symbol curSymbol = new Symbol(production.head());
                curSymbol.setType(s.pop().getType());
                s.push(curSymbol);
            }
            default -> {
                for (int i = 0; i < production.body().size(); i++){
                    s.pop();
                }
                s.push(new Symbol(production.head()));
            }
        }
    }
        ```
        ], caption: "SemanticAnalyzer", numbering: none
)

#figure(
    [
        ```java
    public void whenReduce(Status currentStatus, Production production) {
        Symbol curSymbol = new Symbol(production.head());
        switch (production.index()){
            case 6 -> { // S -> id = E
                Symbol rhs = s.pop();
                s.pop();
                Symbol lhs = s.pop();
                IRVariable tmp = (IRVariable) lhs.getValue();
                curSymbol.setValue(tmp);
                irList.add(Instruction.createMov(tmp, rhs.getValue()));
            }
            case 7 -> { // S -> return E
                Symbol expr = s.pop();
                s.pop();
                irList.add(Instruction.createRet(expr.getValue()));
            }
            case 8 -> { // E -> E + A;
                Symbol rhs = s.pop();
                s.pop();
                Symbol lhs = s.pop();
                IRVariable tmp = IRVariable.temp();
                curSymbol.setValue(tmp);
                irList.add(Instruction.createAdd(tmp, lhs.getValue(), rhs.getValue()));
            }
            ... // 其他产生式
            default -> {
                for (int i = 0; i < production.body().size(); i++){
                    s.pop();
                }
            }
        }
        s.push(curSymbol);
    }
        ```
    ], caption: "IRGenerator", numbering: none 
)

从语法分析阶段和语义分析阶段可以看出，本实验代码实现方面的主要工作在于对文法的 switch-case 语句的编写，以及数据结构的选择和实现。

== 目标代码生成
=== 设计思路和算法描述
首先，我们需要一个数据结构来维护寄存器相关的信息。该数据结构需支持：
- 查询寄存器是否被占用
- 查询某一变量所在的寄存器

为此，首先定义寄存器的表示，可以使用枚举类型：
```java
    public enum Register {
        t0, t1, t2, t3, t4, t5, t6
    }
```

然后实现一个支持双向索引的 Map，用于维护寄存器与变量之间的映射关系：
```java
public class BMap<K, V> {
    private final Map<K, V> KVmap = new HashMap<>();
    private final Map<V, K> VKmap = new HashMap<>();

    public void removeByKey(K key) {
        VKmap.remove(KVmap.remove(key));
    }

    public void removeByValue(V value) {
        KVmap.remove(VKmap.remove(value));

    }

    public boolean containsKey(K key) {
        return KVmap.containsKey(key);
    }

    public boolean containsValue(V value) {
        return VKmap.containsKey(value);
    }

    public void replace(K key, V value) {
        // 对于双射关系, 将会删除交叉项
        removeByKey(key);
        removeByValue(value);
        KVmap.put(key, value);
        VKmap.put(value, key);
    }

    public V getByKey(K key) {
        return KVmap.get(key);
    }

    public K getByValue(V value) {
        return VKmap.get(value);
    }
}

// 实例化
BMap<IRValue, Register> regs = new BMap<>();
```

而后进入目标代码生成阶段。
首先需要对语义分析得到的中间代码进行预处理，主要的处理方式如下：
- 对于一元操作数指令，无需处理
- 对于二元操作数指令，如果两个操作数都是立即数，则直接计算结果并生成 `mov` 指令
- 对于二元操作数指令，如果两个操作数中有一个是立即数，则将立即数加载到寄存器中，并将另一个操作数加载到另一个寄存器中，然后根据操作的类型生成相应的指令


```java
    public void loadIR(List<Instruction> originInstructions) {
        // TODO: 读入前端提供的中间代码并生成所需要的信息
        for (Instruction instr: originInstructions) {
            InstructionKind instr_kind = instr.getKind();
            if (instr_kind.isReturn()) {
                instructions.add(instr);
                break;
            }
            if (instr_kind.isUnary()){
                instructions.add(instr);
            }
            if (instr_kind.isBinary()){
                IRValue lhs = instr.getLHS();
                IRValue rhs = instr.getRHS();
                IRVariable target = instr.getResult();
                if (lhs.isImmediate() && rhs.isImmediate()){
                    int immediateRes = 0;
                    int lhsVal = ((IRImmediate) lhs).getValue();
                    int rhsVal = ((IRImmediate) rhs).getValue();
                    switch (instr_kind) {
                        case ADD -> immediateRes = lhsVal + rhsVal;
                        case SUB -> immediateRes = lhsVal - rhsVal;
                        case MUL -> immediateRes = lhsVal * rhsVal;
                        default -> System.out.println("Invalid IR");
                    }
                    instructions.add(
                        Instruction.createMov(
                            target, IRImmediate.of(immediateRes)));
                }
                if (lhs.isImmediate() && rhs.isIRVariable()){
                    switch (instr_kind) {
                        case ADD -> instructions.add(
                            Instruction.createAdd(target,rhs,lhs));
                        case SUB -> {
                            IRVariable tmp = IRVariable.temp();
                            instructions.add(
                                Instruction.createMov(tmp, lhs));
                            instructions.add(
                                Instruction.createSub(target, tmp, rhs));
                        }
                        case MUL -> {
                            IRVariable tmp = IRVariable.temp();
                            instructions.add(
                                Instruction.createMov(tmp, lhs));
                            instructions.add(
                                Instruction.createMul(target, tmp, rhs));
                        }
                        default -> System.out.println("Invalid IR");
                    }
                }
                if (lhs.isIRVariable() && rhs.isImmediate()) {
                    switch (instr_kind){
                        case ADD,SUB -> instructions.add(instr);
                        case MUL -> {
                            IRVariable tmp = IRVariable.temp();
                            instructions.add(
                                Instruction.createMov(tmp, rhs));
                            instructions.add(
                                Instruction.createMul(target, lhs, tmp));
                        }
                    }
                }
                if (lhs.isIRVariable() && rhs.isIRVariable())
                    instructions.add(instr);
            }
        }
    }
```

对处理后的代码进行遍历，生成目标代码。
需要注意的是寄存器的分配与回收，此处我们的实现较为直接，即每次分配的时候，从枚举的寄存器中寻找一个空闲的寄存器，如果找不到，寻找一个不再使用的寄存器进行回收。

```java
    public Register AllocRegister(IRValue operand,int index) {
        if (regs.containsKey(operand)) return regs.getByKey(operand);
        // enumerate registers to find an idle one
        for (Register reg: Register.values()){
            if (!regs.containsValue(reg)){
                regs.replace(operand, reg);
                return reg;
            }
        }
        // Find registers no longer used
        Set<Register> freeRegs = Arrays.stream(Register.values()).collect(Collectors.toSet());
        for (int i = index; i < instructions.size(); i++){
            Instruction instr = instructions.get(i);
            for (IRValue irValue: instr.getOperands()){
                freeRegs.remove(regs.getByKey(irValue));
            }
        }
        if (!freeRegs.isEmpty()){
            Register alloc = freeRegs.iterator().next();
            regs.replace(operand, alloc);
            return alloc;
        }
        throw new RuntimeException("No free Registers");
    }
```

最后，我们对处理后的代码进行遍历，为每个指令生成相应的汇编代码。
```java
    public void run() {
        // TODO: 执行寄存器分配与代码生成
        asms.add(".text");
        instructions.forEach(instr -> {
            InstructionKind kind = instr.getKind();
            int index = instructions.indexOf(instr);
            String asmCode = null;
            switch (kind) {
                case ADD -> {
                    IRValue lhs = instr.getLHS();
                    IRValue rhs = instr.getRHS();
                    IRValue res = instr.getResult();
                    Register result = AllocRegister(res,index);
                    Register left = AllocRegister(lhs, index);
                    if (rhs.isImmediate()) asmCode = String.format(
                        "  addi %s, %s, %s", result, left, rhs);
                    if (rhs.isIRVariable()) asmCode = String.format(
                        "  add %s, %s, %s", result, left, AllocRegister(rhs,index));
                }
                case SUB -> {
                    IRValue lhs = instr.getLHS();
                    IRValue rhs = instr.getRHS();
                    IRValue res = instr.getResult();
                    Register result = AllocRegister(res,index);
                    Register left = AllocRegister(lhs, index);
                    Register right = AllocRegister(rhs, index);
                    asmCode = String.format(
                        "  sub %s, %s, %s", result, left, right);
                }
                case MUL -> {
                    IRValue lhs = instr.getLHS();
                    IRValue rhs = instr.getRHS();
                    IRValue res = instr.getResult();
                    Register result = AllocRegister(res,index);
                    Register left = AllocRegister(lhs, index);
                    Register right = AllocRegister(rhs, index);
                    asmCode = String.format(
                        "  mul %s, %s, %s", result, left, right);
                }
                case MOV -> {
                    IRValue res = instr.getResult();
                    Register result = AllocRegister(res,index);
                    IRValue src = instr.getFrom();
                    if (src.isImmediate()) 
                        asmCode = String.format("  li %s, %s",result, src);
                    if (src.isIRVariable()) 
                        asmCode = String.format(
                            "  mv %s, %s", result, AllocRegister(src,index));
                }
                case RET -> {
                    IRValue ret = instr.getReturnValue();
                    asmCode = String.format(
                        "  mv a0, %s", AllocRegister(ret, index));
                }
                default -> System.out.println("Error while Generating Asm");
            }
            asmCode += "\t# %s".formatted(instr);
            asms.add(asmCode);
        });

    }
```





#show raw: it => it