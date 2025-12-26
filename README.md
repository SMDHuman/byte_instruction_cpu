# Giriş
  Bu doküman, basit ve verimli bir Komut Seti Mimarisine sahip bir 8-bit işlemci çekirdeğinin tasarım, gerçekleştirme ve performans analizini sunmaktadır. belgenin içeriğini okuyanların mikroişlemci mimarisine ve çalışma prensiplerine hakim olduğu varsayılarak hazırlanmıştır. Kullanılan yöntemlerin örnekleri ve kaynakları projenin ekler kısmında mevcuttur.
## Amaç
  Bu projede tek bayt uzunluğunda komut setine sahip bir işlemci mimarisi tasarlanması ve geliştirilmesi amaçlanmaktadır. Tasarlanan işlemci mimarisinin temel hedefi, basit ve verimli bir komut seti kullanarak her komutun tek çevrimde işlenmesini sağlamaktır. Projenin bir diğer amacı, geliştirilen mimarinin endüstride yaygın olarak kullanılan 8-bit mikrodenetleyiciler ile karşılaştırmalı analizini yaparak avantaj ve dezavantajlarını ortaya koymaktır. 
## Kapsam

Bu projenin değerlendirilmesi ve tasarlanması gereken unsurlar şunalr:
  * Tek bayt (8-bit) komut formatına sahip bir işlemci mimarisi tasarlanacak
  * Her komutun tek saat çevriminde tamamlanması sağlanacak
  * Temel aritmetik, mantık, veri transfer ve kontrol akış işlemleri desteklenecek
  * Basit giriş/çıkış sistemi tasarlanacak
  * Verilog kullanılarak donanım tanımlaması yapılacak
  * C programlama dili kullanılarak çevirici (assembler) ve öykünücü (emulator) geliştirilecek
  * 6502, Intel 8051 ve AVR gibi yaygın 8-bit mikrodenetleyiciler ile karşılaştırmalı performans analizi gerçekleştirilecek

Proje kapsamı dışında kalan konular:
  * Çok çevrimli komut işleme
  * Kesme (interrupt) mekanizması
  * Bellek yönetim birimi
  * Önbellek (cache) sistemi
  * İşletim sistemi desteği
