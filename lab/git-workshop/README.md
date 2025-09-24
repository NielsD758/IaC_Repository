# IAC – Week 3 opdrachten

In deze week heb ik met Ansible gewerkt om mijn servers (`db`, `web1` en `web2`) te beheren.  
De opdrachten zijn stap voor stap uitgevoerd en hieronder beschreven, inclusief de outputs en validatie.

---

## Opdracht 1 – Repo & bereikbaarheid

In deze opdracht heb ik Ansible klaargezet om verbinding te maken met mijn drie servers (`db`, `web1` en `web2`).  
Hiervoor heb ik een [ansible.cfg](ansible.cfg) gemaakt die naar mijn [inventory.ini](inventory.ini) wijst. In de inventory heb ik de servers verdeeld in groepen (app en database) en de juiste SSH-key gekoppeld.

---

### Test 1: ad-hoc commando
Eerst probeerde ik met een ad-hoc commando de hosts te pingen:

```bash
ansible all -a "ping -c 1"

````
Dat ging mis, want Ansible voert dan gewoon het Linux ping-commando uit zonder extra logica.
De volledige output staat in: [ping-ad-hoc.txt](outputs/ping-ad-hoc.txt)

### Test 2: Ansible module
Daarna heb ik hetzelfde geprobeerd met de Ansible ping module:
```bash
ansible all -m ansible.builtin.ping
````
Dit werkte meteen goed: alle servers reageerden met pong.
De volledige output staat in [ping-module.txt](outputs/ping-module.txt)

### Conclusie

Het verschil is duidelijk: een ad-hoc commando is handig om snel iets te testen, maar de Ansible-module is veel betrouwbaarder. Je ziet meteen of de verbinding klopt en het is herhaalbaar zonder fouten.


## Opdracht 2 – Packages & services

In deze opdracht moest ik met Ansible nginx installeren en beheren op de app-servers (web1 en web2).

### Playbook draaien

Ik heb hiervoor het playbook [02_packages_services.yml](playbooks/02_packages_services.yml) gebruikt. Dit zorgt dat nginx wordt geïnstalleerd en dat de service actief en enabled is:
```bash
ansible-playbook playbooks/02_packages_services.yml
````
Bij de eerste run zag je dat nginx geïnstalleerd werd. Toen ik het playbook daarna nog een keer draaide, gebeurde er niks meer (wat juist goed is). Dat laat zien dat Ansible slim genoeg is om te zien dat alles al goed staat, en daarom blijft het netjes op `changed=0`.

### Controleren of nginx draait
Daarna heb ik met een ad-hoc commando gecheckt of de service ook echt actief was:
```bash
ansible app -a "systemctl is-active nginx"
````
De output liet zien dat zowel web1 als web2 gewoon active teruggaven. Top dus.

### Check met curl
Als laatste wilde ik zien of nginx ook echt een webpagina teruggeeft.
Dus deed ik dit:
```bash
ansible app -a "curl -I http://localhost"
````
Beide servers gaven een HTTP/1.1 200 OK terug. Dat betekent dat nginx goed draait en de standaardpagina bereikbaar is.

## Conclusie
Alles werkt zoals het hoort: nginx is geïnstalleerd, draait, en blijft netjes actief. Het is ook fijn dat Ansible bij een tweede run niks onnodigs meer doet.

## Opdracht 3 – Meerdere groepen in één playbook

In deze opdracht moest ik één playbook maken [03_multi_group.yml](playbooks/03_multi_group.yml) dat tegelijk taken uitvoert op verschillende groepen servers.

- Voor de app-servers (web1 en web2) heb ik chrony geïnstalleerd en meteen de service gestart en enabled.

- Voor de db-server (db) heb ik curl geïnstalleerd.

### Resultaat

Bij de eerste run zie je dat chrony geïnstalleerd werd op de app-servers, en dat curl al standaard aanwezig was op de db (dus daar changed=0).
Bij de tweede run kreeg ik overal changed=0, wat betekent dat er niks meer hoefde te gebeuren en alles gewoon goed stond.

Ik heb ook nog apart gecheckt:

- Op de app-servers draaide chrony (systemctl is-active chrony → active).

- Op de db-server stond curl netjes geïnstalleerd (curl --version gaf de juiste versie terug).

De volledige output staat in [opdracht3-run.txt](outputs/opdracht3-run.txt) en de extra checks in:

- [opdracht3-chrony-check.txt](outputs/opdracht3-chrony-check.txt)

- [opdracht3-curl-check.txt](outputs/opdracht3-curl-check.txt)

## Opdracht 4 – Herhalingstaken met variabelen

Voor deze opdracht heb ik een playbook gemaakt [04_repetitive.yml](playbooks/04_repetitive.yml) waarmee ik in één keer meerdere dingen kan regelen op al mijn servers. De details (welke packages, users en files) heb ik in `group_vars` gezet, zodat ik het playbook niet elke keer hoef aan te passen.

### Wat ik gedaan heb
- **Packages:** Op de webservers wordt nginx geïnstalleerd en op de database curl. Dit staat in de variabelen, dus het playbook kiest zelf wat waar hoort. Als ik het daarna nog een keer draai, zie je overal `changed=0`, wat betekent dat er niks meer aangepast hoeft te worden.
- **Users:** Ik heb de users `devuser` en `testuser` toegevoegd, en `olduser` verwijderd. Toen ik controleerde met `id olduser` kreeg ik een error terug. Dat lijkt fout, maar dat is juist goed, want die user moet er niet meer zijn.  
- **Files/Directories:** Ik heb in `/opt` een map (`demo_dir`) en een bestand (`demo_file.txt`) laten maken met de juiste rechten. Eerst stond het bestand op `touch`, waardoor elke run weer `changed` gaf. Door dit aan te passen naar `file` bleef alles na de eerste run gewoon goed staan (`changed=0`).

### Resultaat
- Eerste run: er worden echt dingen aangemaakt (users, bestanden, packages). Zie [opdracht4-run1.txt](outputs/opdracht4-run1.txt).  
- Tweede run: alles staat goed en er verandert niks meer. Zie [opdracht4-run2.txt](outputs/opdracht4-run2.txt).  
- Na het aanpassen van `touch` → `file` bleef het ook netjes goed staan. Bij een volgende run gaf alles gewoon `changed=0`. Zie [opdracht4-run3.txt](outputs/opdracht4-run3.txt).  

**Conclusie:** Het werkt zoals bedoeld. Door variabelen te gebruiken is het playbook overzichtelijker en makkelijker opnieuw te gebruiken. De checks (`id`, `systemctl`, enz.) laten zien dat alles klopt.

---

# Git Workshop


# Stap 9: CHANGELOG en commitconventies

## Bijdragen
Zie [CONTRIBUTING.md](CONTRIBUTING.md) voor de richtlijnen om bij te dragen aan dit project.

## Licentie
Dit project is gelicentieerd onder de MIT-licentie. Zie [LICENSE](LICENSE).

## Changelog
Alle belangrijke wijzigingen in dit project worden bijgehouden in [CHANGELOG.md](CHANGELOG.md).

## Commit conventies
Dit project volgt de **Conventional Commits** standaard:

- feat: nieuwe feature
- fix: bugfix
- docs: documentatie
- chore: onderhoud
- refactor: herstructurering
- perf: performance
- test: tests
