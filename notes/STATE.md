# [STATE](../node_modules/@typesafe-ai/sdk/dist/index.mjs::L190)

```cpp
ModelRequest {
	/** Text, an asset, a JSON object, or an array to evaluate. */
	state: NonNullable<EntryType>;
}
```
> State can be constructed as "asset" Text, JSON object, or an array

> A JSON object seems to encapsulate a good entry point to type state

- [what is NonNullable ? -res](./notes/idris-nonnullable.md) 
- what is EntryType ?

- what is the minimal schema needed to interact with the API, typying the curl request
  - res: [json_ex](####json_ex) 

Our first state **motivation** is 

# [state::cost tracking of token usage](./typesafe-usage-query.md) 






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




