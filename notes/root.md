
# REF
- https://docs.typesafe.ai/introduction
- Idris typed HTTP / curl: notes/idris-typed-http.md
- Idris typed API keys / secrets: notes/idris-typed-api-keys.md
- Idris probability / stochastic: notes/idris-probability.md

# MAIN

(State ,Typed questions) -> StructuredAnswer


Model | State |Questions | 

setModel: Text | Endpoint-> Model;

typeSafe = setModel("typesafe/jev-1.13");
typeSafe = setModel(Endpoint("https://api.typesafe.ai/v1/systemone"));


> How to build state types ?
response = client.system_one(
        state="My running shoes arrived in the wrong size. Can I swap them for a size 10?",

State: [{Listing,{type:, type_ref:}}]


Question: QuestionType -> Answer

Answer: Instructions | Criteria

# PRIMITIVES

QuestionType = Choice | Score | Noul
ChoiceAnswer = Choice | Probabilities | Confidence
ScoreAnswer =  Score  | Probabilities | Confidence 
NoulAnswer = Bool | Probabilities | Confidence


Probabilities: [Probability]
Probability: Criteria -> [0,1]

Choice: * -> Type
> Use when the answer is one of a fixed set of options
> e.g: Get a value from this type class  ?

Score: * -> Num Type
> Use whne the answer is a position on a spectrum 
> e.g: "How severe this bug is ?"
Noul: -> Bool
> e.g Is this value is of this type ?


# ECONOMICS

 : ModelApi |Answers -> Usage
 
 
 "usage": {
    "input_tokens": 328,
    "output_tokens": 34
  }
  
  
 

