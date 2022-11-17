$TTL    36000
@       IN      SOA     ns.fabulas.com. hceamarin.danielcastelao.org. (
                   2022000           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@               IN      NS      ns.fabulas.com.
ns              IN      A       10.26.0.253
maravillosas    IN      A       10.26.0.25
oscuras         IN      CNAME   maravillosas
