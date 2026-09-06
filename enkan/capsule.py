import json, time
class Capsule:
    def __init__(self, sender_id, intent_type, payload, trace=None, created_at=None):
        self.sender_id = sender_id
        self.intent_type = intent_type
        self.payload = payload
        self.trace = trace or []
        self.created_at = created_at or int(time.time())
    def to_bytes(self):
        return json.dumps({"id": self.sender_id, "it": self.intent_type, "p": self.payload, "tr": self.trace[-3:], "ts": self.created_at}, ensure_ascii=False, separators=(',', ':')).encode("utf-8")
    @classmethod
    def from_bytes(cls, b):
        d = json.loads(b.decode("utf-8"))
        c = cls(d["id"], d["it"], d["p"], d["tr"])
        c.created_at = d["ts"]
        return c
