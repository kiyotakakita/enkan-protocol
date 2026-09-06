from .capsule import Capsule
class MatchEvent:
    def __init__(self, past_capsule, incoming_capsule, message, meta=None):
        self.past_capsule = past_capsule
        self.incoming_capsule = incoming_capsule
        self.message = message
        self.meta = meta or {}
class OffGridNode:
    def __init__(self, node_id, location_label, match_rule):
        self.node_id = node_id
        self.location_label = location_label
        self.match_rule = match_rule
        self.archive = []
    def handle_radio_signal(self, raw_bytes):
        incoming = Capsule.from_bytes(raw_bytes)
        event = None
        for past in self.archive:
            event = self.match_rule(past, incoming)
            if event: break
        incoming.trace.append(self.location_label)
        self.archive.append(incoming)
        return event
