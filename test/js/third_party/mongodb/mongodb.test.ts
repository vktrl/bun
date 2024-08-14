import { test, expect, describe } from "bun:test";
import { requireCredentials } from "harness";
import { MongoClient } from "mongodb";

const CONNECTION_STRING = process.env.TLS_MONGODB_DATABASE_URL;

// DO NOT SKIP IN CI.
const it = requireCredentials("TLS_MONGODB_DATABASE_URL", test);

describe("mongodb", () => {
  it("should connect and inpect", async () => {
    const client = new MongoClient(CONNECTION_STRING as string);

    const clientConnection = await client.connect();

    try {
      const db = client.db("bun");

      const schema = db.collection("bun");

      await schema.insertOne({ name: "bunny", version: 1.0 });
      const result = await schema.find();
      await schema.deleteOne({ name: "bunny" });
      const text = Bun.inspect(result);

      expect(text).toBeDefined();
    } finally {
      await clientConnection.close();
    }
  });
});
