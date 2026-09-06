import time
from .node import MatchEvent
def lee_give_matcher_rule(past, incoming):
    if past.intent_type != "GIVE_WANT" or incoming.intent_type != "GIVE_WANT": return None
    past_want = past.payload.get("want", "").lower()
    incoming_can = incoming.payload.get("can", "").lower()
    past_can = past.payload.get("can", "").lower()
    incoming_want = incoming.payload.get("want", "").lower()
    if incoming_can and incoming_can in past_want:
        return MatchEvent(past, incoming, f"🤝 【恩送りの円環が閉じた！】\n   過去にここを通った旅人 '{past.sender_id}' が、\n   まさにあなたの持つ力【{incoming.payload['can']}】で悩んでいました。\n   -> 祠に知恵（アドバイス）を置いていきますか？")
    if past_can and past_can in incoming_want:
        days_ago = int((time.time() - past.created_at) / 86400)
        return MatchEvent(past, incoming, f"💡 【時空を超えたプレゼント！】\n   {days_ago}日前にここを通った旅人 '{past.sender_id}' が、\n   あなたの悩み【{incoming.payload['want']}】のヒントを残していきました！\n   -> 旅人の置き手紙を開放します。")
    return None
