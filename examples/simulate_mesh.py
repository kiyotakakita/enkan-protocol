import time
from enkan import Capsule, OffGridNode, lee_give_matcher_rule
def run_simulation():
    print("=" * 55)
    print("  Enkan-Protocol: Asynchronous Physical Mesh Simulation")
    print("=" * 55 + "\n")
    cafe_shrine = OffGridNode("SHRINE_01", "古い喫茶店の軒先", lee_give_matcher_rule)
    print("🕒 --- [時間軸: 3日前] ---")
    alice = Capsule("アリス(エンジニア)", "GIVE_WANT", {"can": "Dockerインフラ", "want": "看板の木工デザイン"}, ["北の港"])
    sig_a = alice.to_bytes()
    print(f"📡 旅人アリスが通過（LoRa送信: {len(sig_a)} bytes）")
    if not cafe_shrine.handle_radio_signal(sig_a):
        print("   -> 該当者なし。アリスのWantは祠の記憶に静かに眠る（種植え）\n")
    time.sleep(1)
    print("🕒 --- [時間軸: 現在（3日後）] ---")
    bob = Capsule("ボブ(木工職人)", "GIVE_WANT", {"can": "看板の木工デザイン", "want": "Dockerインフラが壊れた"}, ["西の山道"])
    sig_b = bob.to_bytes()
    print(f"📡 旅人ボブが通過（LoRa送信: {len(sig_b)} bytes）")
    ev = cafe_shrine.handle_radio_signal(sig_b)
    if ev:
        print("\n" + "*" * 55)
        print("🎉 【ボブの端末 / AIグラスに直接ポップアップ！】")
        print(ev.message)
        print("*" * 55)
if __name__ == "__main__":
    run_simulation()
