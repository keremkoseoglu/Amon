# Amon
Amon; hem Mısır gök tanrılarından biri, hem de Aircraft Messaging Orchestration Network ‘ün kısaltmasıdır.
## Genel Bakış
Amon’un amacı; koordine görev gerçekleştirecek olan Drone’ların atanması, görevlerinin başlatılması ve görev sırasında izlenmesini merkezi olarak sağlamaktır. Bu amaçla bir iOS uygulaması geliştirilmiştir. Uygulamanın iPad üzerinde çalışacağı öngörülmüştür.
Drone ile uygulama arasındaki haberleşmenin Telegram üzerinden sağlanması öngörülmüştür. Buna göre; Amon’un bir Bot hesabı olacak ve her bir Drone’a özel birer Bot hesabı açılacaktır. Bu Bot’ların tamamı, ortak bir Telegram odasında bir arada bulunacaktır.
Bot’lar birbirine mesaj gönderemediğinden; Bot’ların iletişimi ortak odada ortaya yazılan iletiler üzerinden gerçekleşecektir. 
•	Amon; odaya Bot’a özel bilgi talebi veya komut gönderebileceği gibi, tüm Bot’ları ilgilendiren genel talep / komutlar da gönderebilir.
•	Drone’lar üzerindeki OnBoard yazılım, ilgili Telegram odasına kendisine atanan Bot ID ile bağlanıp iletileri periyodik olarak takip edebilecek kapasitede olacaktır.
•	Bot’lar; odadaki tüm iletileri takip ederek, genel iletilere ve kendisine özel gönderilmiş iletilere tepki / cevap verecektir.
Telegram odasındaki iletilere ait protokol, işbu dokümanın ilgili bölümünde detaylandırılacaktır.
## Proje Yürütme Adımları
Telegram hazırlığı
•	Her bir Drone için bir BOT hesabı açılmalıdır
•	Bu BOT hesabı OnBoard üzerine tanımlanmalıdır
•	AMON için de bir BOT hesabı açılmalıdır
•	Tüm BOT’ların bir arada olacağı bir kanal bulunmalıdır
•	Bu BOT’lar kanalda Admin olmalıdır (Yoksa bot listesi alınamıyor. Telegram API sadece Admin listesi döndürmektedir)
Mission hazırlığı
•	ADA üzerinde PROJE_ID bazlı Mission dosyaları hazırlanacak. Her bir Drone için ayrı dosyalar hazırlanacak. Bu dosyalar, PROJE_DRONEBOT.TXT gibi bir isme sahip olabilir.
•	Bu dosyalar, 24 saat öncesinden itibaren Telegram odasına yüklenecek
•	Drone’lar etkinleştiğinde, OnBoard yazılım Telegram odasından ilgili dosyayı alıp lokaline kaydedecektir
Mission başlatma
•	Amon üzerinde proje tanımlanır
•	Projede çalışacak Drone’lar seçilir
•	Yazılım üzerinde tüm Drone’ların gerekli dosyalara sahip olduğundan emin olunur
•	Drone’lara “Başla” komutu gider. Onboard yazılım, bu komutu duyduğunda görev dosyasını işletmeye başlar
•	Görev sırasında; Amon – Onboard yazılım arasındaki iletişim, Telegram odası üzerindeki mesajlardan gerçekleşir.
## Telegram Protokolü
Projedeki haberleşme Telegram üzerinden gerçekleşecektir. Dolayısıyla; her bir Drone’un Telegram API üzerinden ileti gönderip alabilmesi gerekmektedir. Bu konudaki teknik yönelime https://keremkoseoglu.com/2019/04/29/telegram-uzerinden-iot/ makalesinden erişebilirsiniz.

### Proje yetkinlik sorgusu
Bu sorguda; Amon, tüm Drone’lara PROJ1 (örnek) projesi için gerekli komut dosyasına sahip olup olmadıklarını sorar. Dosyaya sahip olanlar olumlu, olmayanlar olumsuz dönüş yapar.
Amon’dan çıkacak sorgu:
/setup_for_project drone:DRONE01bot project:PROJ1
Tüm Bot’lardan beklenen olumlu cevap:
/my_project_setup drone:DRONE1bot project:PROJ1 success:TRUE
Tüm Bot’lardan beklenen olumsuz cevap:
/my_project_setup drone:DRONE1bot project:PROJ1 success:FALSE info:FILE_MISSING
Info değeri serbest olup, durumu özetleyen bir ifade konabilir.
### Projenin başlaması
Bu komutta; Amon, istenen Drone’la (örnek: DRONE1bot) PROJ1 (örnek) projesi ile ilgili görev dosyasını işlemeye başlamalarını söyler. Drone’lar, başladıklarını veya başlayamadıkları konusunda dönüş yapar.
Amon’dan çıkacak komut:
/start_project drone:DRONE1bot project:PROJ1
DRONE1bot’tan beklenen olumlu cevap:
/my_project_start drone:DRONE1bot project:PROJ1 success:TRUE
DRONE1bot’tan beklenen olumsuz cevap:
/my_project_start drone:DRONE1bot project:PROJ1 success:FALSE info:BATTERY_ERROR
Info değeri serbest olup, durumu özetleyen bir ifade konabilir.
### Drone durumu
Bu komut ile; Amon, istenen Drone’un (örnek: DRONE1bot) güncel durumunu sorgular. Drone, aşağıdaki formatta istenen bilgileri döndürür.
Amon’dan çıkacak komut:
/get_status drone:DRONE1bot
DRONE1bot’tan beklenen cevap:
/my_status drone:DRONE1bot project:PROJ1 started:TRUE active:TRUE finished:FALSE pos_lat:41.092850 pos_lon:29.097709 height:50 base_lat:41.092850 base_lon:29.097709 mission_steps:12 complete_steps:4 battery:62 info:NONE waypoints:[40.123456-29.098392;40.123457-29.098393;40.123457-29.098393] complete_waypoint:2
Buradaki değerler;
•	drone: Cevap veren Drone’nun adı
•	project: O anda etkin olan projesinin ID’si
•	started: Projeye başladıysa TRUE, başlamadıysa FALSE döner
•	active: O anda projeyi sürdürüyorsa TRUE, sürdürmüyorsa FALSE döner
•	finished: Projeyi bitirdiyse TRUE, bitirmediyse FALSE döner
•	pos_lat, pos_lon: Mevcut konumunun koordinatları
•	height: Yerden yüksekliği (metre)
•	base_lat, base_lon: Base’inin koordinatları
•	mission_steps: Mevcut görev dosyasındaki adım sayısı
•	complete_steps: Kaç adımı bitirmiş olduğu
•	battery: Pil doluluğu % olarak
•	info: Serbest bilgi iletilebilecek bir alandır. Bilhassa bir hata varsa / olduysa, bu hata söz konusu alanda iletilebilir.
•	waypoints: Drone’un görevinde izlemesi gereken koordinatları barındırır
•	complete_waypoint: En son kaçıncı koordinatı tamamladıysa onu barındırır
Bir Drone, özel bir durumda Amon’dan sorgu beklemeden de kendi statüsünü bildirebilir. Mesela projeyi başarılı tamamladığı durum buna örnek olabilir.
### Projeyi erken bitirme
Bu komut ile; komut dosyası bitsin bitmesin belli bir Drone’a (örnek: DRONE1bot) işi bırakması söylenir. Bu bilhassa olumsuz hava koşulları gibi hesapta olmayan problemlerde gerekebilir.
Amon’dan çıkacak komut:
/abort_project drone:DRONE1bot project:PROJ1
DRONE1bot’tan beklenen olumlu cevap:
/my_project_abortion drone:DRONE1bot project:PROJ1 aborted:TRUE info:blabla
DRONE1bot’tan beklenen olumsuz cevap:
/my_project_abortion drone:DRONE1bot project:PROJ1 aborted:FALSE info:blabla
Bir Drone, özel bir durumda Amon’dan sorgu beklemeden de projeyi erken bitirdiğini bildirebilir. Mesela arıza nedeniyle işinin yarım kaldığı durumlar buna örnek olabilir.
Kamera görüntüsü
Bu komut ile; Amon, bir Drone’un kamerasından (örnek: DRONE01bot) o anki görüntüyü talep eder. Drone’nun kameradaki görüntüyü elde edip, Telegram odasına bir fotoğraf olarak atması beklenir.
Amon’dan çıkacak komut:
/shoot_photo drone:DRONE1bot
DRONE1bot’tan beklenen olumlu cevap:
/my_photo drone:DRONE1bot photo: AgADBAADNbExG7y4cFFunYKwAtmdmT4EIhsABH7Hd5ye3fXOokkEAAEC
Bu cevap içerisindeki photo değeri, Telegram’a fotoğraf gönderildiğinde dönen FILE_ID değeridir. Örnek Telegram cevabı şöyledir:
chat {"ok":true,"result":[{"update_id":910197241,
"message":{"message_id":13,"from":{"id":883393886,"is_bot":false,"first_name":"Dr. Kerem","last_name":"Koseoglu","username":"keremkoseoglu","language_code":"en"},"chat":{"id":-366311106,"title":"kkbots","type":"group","all_members_are_administrators":true},"date":1554891927,"text":"kerem test iletisi yeni"}},{"update_id":910197242,
"message":{"message_id":14,"from":{"id":883393886,"is_bot":false,"first_name":"Dr. Kerem","last_name":"Koseoglu","username":"keremkoseoglu","language_code":"en"},"chat":{"id":-366311106,"title":"kkbots","type":"group","all_members_are_administrators":true},"date":1554892004,"text":"{\"type\":\"command\", \"to\": \"bot123\", \"command\":\"dummy\"}"}},{"update_id":910197243,
"message":{"message_id":15,"from":{"id":883393886,"is_bot":false,"first_name":"Dr. Kerem","last_name":"Koseoglu","username":"keremkoseoglu","language_code":"en"},"chat":{"id":-366311106,"title":"kkbots","type":"group","all_members_are_administrators":true},"date":1554892091,"photo":[{"file_id":"AgADBAADNbExG7y4cFFunYKwAtmdmT4EIhsABH7Hd5ye3fXOokkEAAEC","file_size":1831,"width":90,"height":73},{"file_id":"AgADBAADNbExG7y4cFFunYKwAtmdmT4EIhsABHHbrosp10scoUkEAAEC","file_size":4144,"width":108,"height":88}],"caption":"test_caption"}}]}
DRONE1bot’tan beklenen olumsuz cevap:
/my_photo drone:DRONE1bot info:blabla
## Amon Özellik Listesi
### Version 1
•	Projem
o	proje bilgileri: PROJE_ID, isim, ıvır zıvır
o	telegram oda adı
o	projeye drone ekle / çıkar
o	proje başlatma
	tüm drone'lara "mission var mı" diye sor
	mission herkeste varsa başlat
o	% kaçı bitti
o	abort / tamamını
o	REFRESH ALL butonu
o	kill switch
•	harita üzerinde drone'ları göstermek
•	bir drone'un detaylarını göstermek (master -> detail)
o	konum (sayısal) + yükseklik + base point
o	benden ne kadar uzakta?
o	o anki görev listesi + kaçıncı satırda
o	kameradan o anki görüntü
o	pil durumu
o	harita üzerinde nerede
o	geri çağır
o	REFRESH butonu
### Version 2
•	auto refresh
•	drone'lar fazla yaklaştıysa uyarı
•	loglama (görev sırasında neler oldu) + export
•	onboard'ın geribildirim vermesi - alarm, bozuldum, vs
•	telegram harici offline iletişim protokolü
•	güvenlik: drone’lar, iletilerin amon’dan geldiğinden emin olmalı. Onboard’da amon’un user ID’si de belirtilebilir.
•	Drone bazında “Abort Mission”

# Mut
Mut; Mısır mitolojisinde Amon’un eşi olarak geçer. Aynı zamanda, Message Utilities & Tracking ifadesinin kısaltmasıdır.
## Genel Bakış
Mut; mobil cihazlarda çalışan Amon yazılımlarının merkezi işlevlerini yerine getirmek üzere tasarlanmıştır. Python dilinde yazılmış olup, https://amon-mut.herokuapp.com adresinde koşmaktadır.
## API işlevleri

https://amon-mut.herokuapp.com/api/appRunning?device_id=123 adresi üzerinden, Amon’un bir cihaz üzerinde kullanıldığı belirtilmektedir. Şu anda bu adreste bir kayıt tutulmamakla birlikte, ileride istatistiksel veriler için kullanılabilir.

https://amon-mut.herokuapp.com/api/getAmonConfig adresindeki konfigürasyon üzerinden, Amon uygulamalarının çalışması veya çalışmayı reddetmesi sağlanabilir. Örnek format: 
{"is_disabled":false}
Amon uygulaması; herhangi bir sebeple bu adrese erişemiyorsa veya adresten hata dönüyorsa, normal şekilde çalışmayı sürdürecektir. Ancak buraya erişiyorsa ve is_disabled değeri true dönüyorsa, çalışmayı reddedecektir. Bu sayede; herhangi bir risk veya hata fark edilirse Amon uygulamalarının merkezi bir yerden durdurulması sağlanabilir.
