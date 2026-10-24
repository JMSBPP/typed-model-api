

such that we can explore under gitignored node_modules its content
		   It has client.system_one(state = {"": ""})
		   it also has  state= ["The customer returned this item:", Image(returned)]
		   Then state seems to be "polimorphic" 
		- once from there we write the semantics of our own
			- This all goes under the worktree type/state
		      - for the semantics note that state encodes the prompt and the env/context
                where it "lives"
	   - We need to design our first controlled "mock case" for the unit test, this we need a constructor of state

ModelRequest {
	/** Text, an asset, a JSON object, or an array to evaluate. */
	state: NonNullable<EntryType>;
}
- what is NonNullable ?
- what is EntryType ?

This seems to imply that State can be constructed as "asset" Text, JSON object, or an array



- what is the minimal schema needed to interact with the API, typying the curl request
  - res: ####[json_ex](./json_ex) 
- we need to consider importing thr `curl` idris2 library and/or the `http` related libraries
  - res:

- we need to consider this integration https://jev.agents.bakingbad.dev/openapi.json for x402 payments. From now the 25 budget is to be spent on testing. BUT we need to control it and that is our test cases
for developing our system

- This is our state is a reference to the cost tracking of token usage 

- Then the question is how does https://console.typesafe.ai/usage or in general one can programatically query via a wss or live daemon the usage ?

A JSON object seems to encapsulate a good entry point to type state



#### json_ex

```
curl --request POST \
  --url https://api.typesafe.ai/v1/systemone \
  --header 'Authorization: Bearer <token>' \
  --header 'Content-Type: application/json' \
  --data '
{
  "model": "jev-latest",
  "state": "I was charged twice for my subscription this month. Please refund the extra charge.",
  "questions": {
    "billing": {
      "type": "noul",
      "instructions": "Is this message about billing?"
    }
  }
```

The example above shows a requirement once we define a state the minimal model set up and empty questions what is the expected result ?




NonNullable<EntryType>


