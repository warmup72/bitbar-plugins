#!/bin/bash
# <bitbar.title>TMLogBar</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Simon Egerland</bitbar.author>
# <bitbar.author.github>warmup</bitbar.author.github>
# <bitbar.desc>Watch the Time Machine Log</bitbar.desc>
# <bitbar.image>http://www.hosted-somewhere/pluginimage</bitbar.image>
# <bitbar.dependencies></bitbar.dependencies>
# <bitbar.abouturl>http://url-to-about.com/</bitbar.abouturl>
scriptpath=$(cd $(dirname $0); pwd -P)
mailpath="${scriptpath%/*}/sendmail.sh"
workpath="$(defaults read com.matryer.Bitbar | grep "pluginsDirectory" | cut -d"\"" -f 2)/TMLogBar"
templog="tm_temp.log"
configfile="TMLogBar.conf"
version="2.1"
deb="off" #pars = deb ohne File; on = deb mit vorhandenem File; off = Prod
tme=1 # Internal Functions (Time Machine Editor, Timedog, Mail)
loglevel=0 # 1=on   0=off für tm_wait Launchctl-Daemon
#--- TM-Clock-ICONS ---
img_nothing="iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAADAFBMVEUAAAAAAAAOEBI/REwhJCkeISUFBQY3PEM9QkoXGRxFS1RDSVEICQoPEBNITlc1OUAeISRDSFIVFhkICQsMDRAfISUQERIzNz8ICAkICQs0Oj8FBQZARU4nKS0fISUNDRAXGhw0OUM1OkEPERMfIiVBRk4eICMaHCYhJCkUFRlnbXUjJisICQozOD8lJytARU5obXYHCAkQERNKUFohIyYFBQZBRk43PEROVFw0OUEJCQseICQ0OEFLUlpMUloOEBIHBwkxNTtBRk80OUIdISQzNz0eISU3O0EPEBJBR08RExUGBwhBR08QERNqbnY0OT8iJisgIyYeISRFSlRNUlpobXUzOkBobnYREhNES1Q2O0ESFBY2OkEfISYJCQtBR1BPU1w4PEMODxAjJis0OD4VFhk8Qko0N0FFS1RES1QTFBcUFRZOUlo4PENobXY0OD82OkI2OkIcHiZPVV1obnZpbnYdICM1OkJPVV4iJiscHib////t7e7q6+zt7u/Fx8qlqKykp6vCxMhKUFrGyMvAw8bb3d7Ex8rBw8ahpKnt7u6kqKygo6fw8PHg4eNscXjw8fHMztHh4uOjpqvNztEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlCNKjAAABAHRSTlMAAR+pUkQKpb020ccFF9mPRMcoBRJGF2QCDYoFx0xFEjaOqhhHtz49USj3ag1pScb6Agv+PAa6pNiLDkOJ1NQXBYnKqUKIQ4EWzAsFyA35p2s9PtLW94n6E9KSII1FDcXXgQxshSe9idLRIBPWpfinkqY/1Pj6PqXUbD7//////////////////////////////////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHUzbfAAAARJJREFUeJxiYMADrDhZWDjjUISULQXTctk5BNN5EWIqXDGpIFqIP8MNJsbGHAskhYWBBCufC1SQ0ZCBoaiwuKK8ioFBINMDbkByXtOUiU0llQwMBSkwMTW/ruqGydV1pWUMWfFG0hBBpZbq6obG6ur6/OxEJ1VxBgYmPQZvi5rq6u7+xkkTcpIcm2VEGOT1jV29QoCCbZ09fb0JDgyyTAwMumae7hH+9dVg0O4MMc7U1yeaISi8BiRWZ6AOszosioEhILSjtrZVSxvuRvtgAQaGQHY7W3MTBgYJRqioNR8rkOThARJyzGwwtayR/EIgWlORSxQRTLw23Bzs7BzcUmIoIarDyaKhIIkvGgAAAAD//wMAOiw5D091XOYAAAAASUVORK5CYII="
img_good="iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAADAFBMVEUAAAAFBQYAAAAOEBI3PEMhJCkeISUJCQw9QkoXGRw/RExFS1RDSVEPEBNEUlFITlc1OUAeISQ6OUZDSFIVFhkMDRAfISUQERIzNz8ICAk0Oj8ICQsFBQYnKS1ARU4fISUNDRA0OUMXGhw7OkgfIiUPERNBRk4eHCshJCkUFRkiICgICQpARU4zOD8lJytMb1VLb1QoJjIHCAkQERNKUFoFBQZBRk4lIioJCQs0OUE+PUpHVFQ0OEEOEBIeICQxNTs6OUkIBwpBRk8PEBIdISQeISU+PUpMcFU3O0FBR08zNz0HBwoTExZBR08QERMlIitFU1I2O0FES1RLb1UzOkASFBZLcFUSEhRFSlQoJTIjISk2OkEfISYJCQsPDxJBR1BHVFM4PEM0OD4oJTI8QkoVFhk0N0FFS1RES1QUFRdGU1ITFBdLb1U4PEM2OkI8O0kgHStEVVE8O0koJjJMcFUhHyhMb1UgHipEVFEg/wQe/wEf/wI9yjEp8BId/wAf/wMp7xMo6xI7xi8s5Rgc/wBKUFoh/wY73SpSpFBVqFNUo1Io8RFdcWdXp1Uo8hE8xy9SqU9Sp09XqFQ7xy8v1h4w1h5RqE4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACndwm4AAABAHRSTlMACgEfpVJEBb02qdHHF9TZj0SnxygSRhdkAooNBUzHRRKONqpHGLc9USg+DcZpSfr3agIL/ga6PA6LpNiJF0OJqQXKFkJDpfmByIgFC8wNPdaS0veJIPoT0ms+jUUNDMXXgYVsvSeJ0tET1iD4pZKmP9SlbPo++D7U////////////////////////////////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG41JwgAAARdJREFUeJxiYMADLDhZWTljUYRULYVTclk4hNN4EWIq3NGpIFpEIN0VJsbIFQMk2dmBBBu/C1SQyYiBoSC/sKKonIFBMMMZbkByTv+UqZPLihkY8pJgYlrutS0TprXUlpQyZMcby0AElWuqqnsn1tXVCGUmOqlJMDAw6zF4WzdUVnf2TGruy4qzb5UTZVDQMfHyCWiorG/v6GruTnBkkGVmYNA18/UIF6qpaquvrq6rcYAYZ+rnGcoQFVZbVVlZVauvDrM6JJCBITK4qbGxycAQ7kbbCEEGBn83Pj4rcwYGSSaoqB0/G8yb8lyMMLVsQQIiIFpTkVsMEUy8NjwcLCwcPFLiKCGqzcmqoSSNJxYYAAAAAP//AwDBnzh4eFRtvQAAAABJRU5ErkJggg=="
img_caution="iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAADAFBMVEUAAAAAAAAFBQYOEBIXGRweISUhJCkJCQw3PEM9Qko/RExDSVFFS1REUlEPEBM6OUZITlc1OUAeISQVFhlDSFIeHCsICAlMb1UQERIfISUMDRA7OkgoJjIfISUICQs0Oj86OUlARU4nKS1Lb1QzNz8iIChBRk4FBQYNDRAlIio0OUMXGhw+PUohJCkUFRlARU4zOD9HVFQlJysHCAlMcFUICQpHVFMfIiUPERMxNTsIBwoQERNBRk8+PUoHBwo0OEFKUFoFBQZBRk4zNz1BR08QERMTExYeICQ3O0EOEBJBR09BR1A4PEMeISUPDxIdISQPEBJFU1JLb1USFBZFSlQ2O0EzOkAjISlLcFVES1QoJTISEhQlIisJCQs0OUEUFRc0OD4TFBdGU1I2OkIoJTIhHyhES1QJCQtFS1Q0N0E2OkFLb1UfISZMcFU8QkogHSsVFhkoJjJMb1U8O0lEVFFEVVE8O0kgHio4PEP9mgxSpFBKUFpUo1JVqFNdcWdXqFRXp1VSp09SqU9RqE4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADO2Z9HAAABAHRSTlMAAQofNkRSBaW9qcfR1Ben2Y9EKMc9AvoXRhKqakUNiqnHTPdkPrcFEjyONqRRKMZp2EkC+Q3XRxiJBQvKpQWJ/ga6iMwNC0OBF8jFgUMMQhbW9yDSkok++tJrEz0OixOFINaSbD7RDdKJjfhF+r0/J2z4pdTUpj6l//////////////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2yR62wAAAQRJREFUeJxiYMADYlnY2FjSUYQs4kTyKjg4RTL5EGLmPFkFIFpYMMMXJsbElQMk2dmBBKuAP1SQ0ZiBIb+stKS4nIFBKC0AbkBKdiUQFBUyMCQnwMRUTSorm5orK3NTGRK9rdUhgtJAZQ2NQII/3sdGTYWBgdmIwc4QyK+tq6+sTPKzrFaUYtDQd3B2CwSZWFVTWWlmxaDEzMBg4OTiEc1fCQUKEOMcXb2CGcIjIGLiojCrw0IZGKKCQGLKMnA3eoYIMTDE2PLy6mgyMIgxQkXdBVhh3pTlYoKpZY0UFAbRelo8kohg4rPn5uTg4OSWl0AJUVMWNl1tOZxxAAQAAAAA//8DAIHdNqEHyXhyAAAAAElFTkSuQmCC"
img_error="iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAADAFBMVEUAAAAAAAAOEBI/REwhJCkeISUFBQYXGRw9Qko3PENFS1RDSVEPEBNqTFUICwxMSVFITlc1OUAeISRDSFIVFhkiLTIICgxPSFEMDRAfISUQERIzNz8ICAk0Oj8ICQsFBQYnKS1ARU4fISU0OUMXGhwNDRAfIiUPERNBRk4hJCkaISsUFRk2QUgICQpARU4lJyszOD8iLTJpTFQeJSgHCAkQERNBRk4FBQZKUFo0OUEJCQsgKCoOEBIeICQ4Q0o0OEFOS1QeISUdISQPEBIxNTsHCQpBRk81QEkRFBY3O0FBR08GCAprTVYzNz04Q0oQERNBR09FSlRNSVIeJikgKCszOkASFBY2O0EREhQ1P0ZpTFUiLTJES1QJCQsfISY2OkFPS1NBR1A4PEMOERI0OD5ES1Q0N0FFS1QVFhk8QkpOSlIUFRcTFBc4PEM2OkI0P0ZpTFUbIys2QUk2QUkdJChqTVVqTFUbIyr/AAX/AAL/AAP/AADrDhTuDRLDKjDqDRPGKzL/AAHuCxHuDRPiExnEKzDUGh9KUFrHKzL+AAT/AAT8AQfaJSvGKzGgSlGjTVSfTFJsYGejT1WlSU+lT1SjSVCkSE4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABzbxMHAAABAHRSTlMAAR+pUkQKNr2l0ccX+gXU2Y9ExyhsBdQSRhdkAooNBUzHRY42EkcYt1E9KKoNxklpavc+Agu6Bv6LDjwXQ6SJ2ENCFokFyqkLgcwF+YilDcjS1j49iSCSE6f3a9INRY3XxYEMhdGJ0ie91hMgpZKn+D+mpT76+D7/////////////////////////////////////////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdBzbzQAAARlJREFUeJxiYMADrNhZWNhjUYTULYUzczk5hNN4EGJqXPEZIFpEMN0RJsbGHAckxcSABKuAE1SQ0YSBobBIXLy4nIFBKNUZboBoQWtbW2uZKANDXgpMzNinuXrytOrm0hKGnERTeYigTkdl1aSp1Y0N+dlJbhrSDAxM+gzeDjUVVf0Tp7Q0ZSW7tCtKMKjqWfh6BNVUdPb0TWhpSnBlUGBiYDAw8/KMiGyo7O6qqmrsdYcYZ+4fEMYQzFtbWVFRWcurBbM6NJyBITqqrr6+zsgQ7kabQCEGhhA/fn47awYGGUaoqK0AK5Dk4wMSSsxsMLWsMYIiIFpbmUsSEUw89twcnJwc3LJSKCGqy86iqSKHLxoAAAAA//8DABGgODVcrNo8AAAAAElFTkSuQmCC"
#-Backup-Mode-Icons-
bmode_auto="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAklJREFUeNqkkltrE1EQx2eTzZru9iEpKG3T3LxgoaBJNy+SIPRFUPMN/AZaUkrRmMTYJ0GtqJSq+Dm0UHxLsFi8oqAJ3pqaRDHpU5ts95ZdZ7ZJsTURwQPDycmc/c9/fnMY0zThfxZ7Y+428DwPKNTAs6CqKsNxHKk2GYbplyRp5zIVEwTB2jEHzWYTWEo0Gg1QVeVVX5/zpGHAd8PQYWtLfs1x+8Bms/3dAVVCxZ/BQNATi0UBqw+hC3i6vHyiUqk+wvwERn9PAUVRaigQFEURCsUifPr8BY4cPgTiuMiurpbiZJfC5XIBCe9lZpvNpuObmxsvWq0WFD4UYDpxIUI7nRVFrl9JJyNutxs6QnsXk8nOFvHy0TNn41Apl6FU+gqBwEHwer2wuPjYgjU87PlmGIavG2BW03SfpmnVlWcr+0Oh49zg4BDouga5XA4hS2sMgH19vf4RJ+UzDPMPwJiHMIY2mZhasttZjyzLL51OZwSrFUdGvCim60G/PxiNRQWsDm3AOgLG+/YJ9nI6+0aSmtTOADpZe/jg3rnzk4klVHfjtz+w79B4D8AWhFTmKkxNz0DbydjFZIp+j2EcwxiduZR8/vbde3Pu1h3qXaSdzqlMtk5nhgTIAcGy5sqylk0aG4IroIvRXoCxhe2X+PtTdTg4FKFeNRLwdwOcz+dVRVFrDodjgO3+vrbnffP6tWgHcLVa3gGMY68vzN89TYZ3tUAOeF7Y9WDagCVspXZ/Yf4UAn6CbR7A/3i6+68r3AbbARzuJH4JMADwfltNwWVMFAAAAABJRU5ErkJggg=="
bmode_man="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7EAAAOxAGVKw4bAAACsUlEQVQ4y5XTS0hUURgH8O+ce+fcmdGxGXN0RsccFS17OZJoI2IvMsKQkAyKSByKQcw2gRBEBBa2iJCghxRkG3GR1SIhsY2EOK7EUEIFaTQfo97RO87jel+nhQ/QpqBv+Z1zfnwH/h/AP+pRY5X35LHcHPifammoun7rcvm582UHCiNjn+jHtsZXxQWO9M5Wz5PCPHvK7vvs7kaTp7ZNWhfnG+4/9yLMgtFgMF27cLy+pvbqne/jP0dHJuc7/gBc+elpl864LrZ/GHgDAArRG2yplkQCCAHRscTpsGUDVSEUEUNxJ6irdt/0eupaZgJBv6rKYR2X4LTtNSUghIEQHdmXkZalqTIEhehSXIBfCS0hlkDx4Vx3OBILJRvNyJ6SlAEIgZ7TEYc91akpMvBCdDkuMBNYmdZkEUpdBaUxUQxjhkCW3ZKJEIYMq9nA6Y2ZVJWBFyLxJ5hdFPyqHIOcvIJKhBnKcEZwl59qBoTBZN1XgVmCpPCywq9Gg94a9+mK4v3VPf0jXZ29wz4WAODXouBXpRhlExMQYlgEmgYk0coCpcAQA6KaCqos8pXu/KLW5vrPDMsZOJZhO3uHfWhrFH7gxQqXlGpGmAWEMADCmycaiEIAVHFNwjp9mOWMyQODvtfeh123ZwKr4nYOopHwnM5oNiOsbgIbtiKuAUIYuD02QjUlefzHaM+Vux1eISzSHUGaW+TnkizWgxQzOwBNWQeGGIEqEkgxIdT0uOvG1uMdwOwC78/PlQAw3gAAAQAFhBjQlHUAqkG/b+Tt0Oj0Qtwo9w2Ova8oOeTBjA7RbQAAgAJQDVRJjLV3f3v211142T34peSI817ViaIHmCE6tPkFSjWQJXH56bteT9/Q5NRuAO1ulB11Ospd2WetFpNdVhTJPx+c6Bua+Do1G4zG297fpQQSsoIeAVoAAAAASUVORK5CYII="
bmode_undef="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADPklEQVR42lVTXWhcRRT+zsy9d/+6yaZbk5hECk3bpBRaBU3zoIQQi1VqsgYSaqFotD+IgoiPBQVBRRBFUFQUFHxLoKS11EKtebGoFG3aagkRgyZpd7XZzSa7e3fvvTsznr2lpR2Yl8Oc7+/MIWMM7j76yGsZwIyT7QxSMpFs1EypUkLgzxjQpPjiw+m739NtgNrhV9uF0p+ITelR2bsNdH874Di3XgU+9I0c9Nw89MrqCS3p5eiXH+XuAJQmXumSRp+ze7b3Wg/uAiIOyLIA22Z6JvB8mLri66N+6Srq8/NzisTe5FcfL4cAa4eOnXS6u4cjD+0GKQ1s7gTt7AGikVsK1kswl/6AyRdghIA/exn+Xwunmr/5fIRuHnxxxGpqmk709UHYzMxM1LMF9PBuoFQGUk0AN2GlAHX6PGAJaN9H5eJF1NfXM5Q9MDGZ6N46FuvqYj8NUwSKREGxKANUgMf6QL1bgIoL9fUUDCG81eUluAsLU7R84Plsy/Yd7XYsAZISJCSHVgdVa0AsAnHkIJBOwcxegz7zA4wtoVllUK2g+OdcjhafnXDTHZtjVoPVC4BCkT2XQb4H+fox0EA/zPV/oY6/B1PzgNaNMIk4D6aG1exSlRbGDrmtza0x6dZAhVW2IBouIHZsg/X+G2GG9ePvQv/2O0snGFZnkhugUkncLOerdO2Z8WxHTbY7lWqYOjVGKAjykV2QR58DeP7BB5/CcAYmUKEKw2S+JZFN2Tm6PDw6mV7zxlo0e4+zjbgD4digjjbIJ4ZgFq9DX/iJk6+HzdplG0xWFAb5VGSKft2fGXECPf2Aq2AnOPlEDI0c7aMvQA4NAooDe/MtqH+WoGsBTLmKOgMsxiUCW2bCj/TzU0+fTPt6uMNi9iRPwyEGOAw5MMABBAjeeRvq7yW2wQrWyrjBtbwjTvWf+XYkBPhl3/6uQKuzmyB3djJAdOMGiM42iP49QDEPPXsFuujCy69jmSe0YtQVW8h9e86ezt5Zph/3PnlfYNRncSFG25qTSLc2I9LCajgsj5vz2QJyqyW4Wp2wSb706Lnv/rtnG2+f7weHMlwbF0SD0agTrrPnBSWl9QwRTT4+c/6edf4fE/2AG26TaX0AAAAASUVORK5CYII="
#--------------
tmicon="iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAACjUlEQVR4nHxUTW8SYRBeIAYwUSEkrOnVnmyhUelB1Jt/pNCbmpCYGHoAkh45tE3bQy89GXohMcLFQ5cDtGCMRgxWD7YmkDZ8yIJ2y9cuuzvOYEv42HWSN5l9Z/bJO/M8MwyjYzdMJqvbZrvzgGW9dMinO738gZmNxmtGhjGQf9tstr1aXHxxsLycqq6slBqRSIsO+sUDvz+FseeYc0sTaN5uvxdYWAg8nZm5f+jz7cvRqCptbUF7b08UkklRSCQl9CVpexsolvX79x87nXNTQHftdk8pGKzy4XBN3NwE/LndOz3tyaLYlwGUwUFfLJcJuCOvr8NJIPD1kdM5Pwbkdjg89dXVc3ltDZq7u2K/2+2DhpWqPPB/BPkinR6A5Xw+blimwWBgQktLL9s7O4qwsQF8NApNjgNQ1TEQvikAd/gZOj0JQ6osJBJdBXOpZwMgh9V6PR+PZ5TjY+iWy0qvVgOpXh8DEiUJUrk8VH41hne9s7NeH3uW8fu5myaThXHZ7bOVUKjUjsclVZY1Szr6UYT8t5OxOwV71orFpEowWEJpzDIeln3YiIRb+FQJUZRJkMyHAsTepkCWx0OUS2w2wuELxPASkJd0gmxoAmU/HcHrNxw0fgv/B3JjaSQ80gk9V6s0vnkO79IfoTzSo6nSqFHYsBQ1jhqoBURWqTfhy/efxNjgm3JJtMNmkxGFRCVRStTqgV3xOEH/s6EgSVQkLhKZkE63VUXRB8OYcCnI9/iaqblDuc+h7AsDsESiQ0+fHBEcG5FecjkihScsOz1vZDSI2fGhlYgZYrRFQ4t3FMvh0OqCjJZJPcOVwSEjxas1Qj7dUU9014iW4RKzuEYWm+vfYrPo5f8FAAD//wMAyN3ziLyVt/gAAAAASUVORK5CYII="
if [ "$deb" != "off" ]; then
    set -x
    workpath="/Users/Simon/Desktop/TMLogBar"
fi
# --- Help-Functions ---
function send_message {
    if [ "$init" = "0" ]; then
        result=$(osascript -e 'display notification "'"$2"'" with title "'"$1"'" sound name "glass"') 
        if [ $failed -gt 10 ] && [ "$tme" = "1" ]; then
            ${mailpath} "$2" "$1" > /dev/null
        fi
    fi
}
function get_tm_log {
    if [ "$deb" != "on" ]; then
        lookbackhour="$(echo "scale=0;(($1/60/60)/1)+3" | bc)"
        logtime="$(date -j -v-${lookbackhour}H +'%Y-%m-%d %H:%M:%S')"
        log show --style syslog --start "${logtime}" --info --predicate 'processImagePath contains "backupd" and subsystem beginswith "com.apple.TimeMachine"' > "${templog}" 
    fi
}
function choose_value {
    result=$(osascript -e 'set mainList to '"$2"'
            choose from list mainList with prompt "'"$1"'"
            set listchoice to result as text')
    if [ "${result}" = "false" ]; then exit; fi
    echo "${result}"
}
function getpid {
    pid="$(grep -E  -o "\[[0-9]*\]" <<< $1)"; laenge="$((${#pid}-2))"; pid="${pid:1:$laenge}" 
    echo "${pid}"
}
function i_getlogdate {
    datum="${line:0:10}"
    hour="${line:11:2}"
    minutes="${line:14:2}"   
    time="$(date -jf "%Y-%m-%d %H:%M" "${datum} ${hour}:${minutes}" +%s)"
}
function write_header {
    echo "#Lastrun;Keep last Logs;Last State;BackupInterval (h)" > "${configfile}"
    echo "${saverun};${keeplog};${laststate};${tminterval};${lasttm}" >> "${configfile}"
}
function read_header {
    cd "${workpath}"
    data_line="$(tail -n 1 ${configfile})"
    lastrun=$(echo $data_line | cut -d ";" -f 1)
    if [ "${lastrun}" = "" ]; then lastrun=$((${aktdate_s}-(5*60*60))); fi
    keeplog=$(echo $data_line | cut -d ";" -f 2)
    laststate=$(echo $data_line | cut -d ";" -f 3)
    tminterval=$(echo $data_line | cut -d ";" -f 4)
    lasttm=$(echo $data_line | cut -d ";" -f 5)
        if [ "${lasttm}" = "" ]; then lasttm="${aktdate_s}"; fi
    get_tm_log "$((${aktdate_s}-${lastrun}))"
    init=0
}
# --- Functions ---
function initial_start {
    aktdate_s=$(date +%s)
    if [ ! -d "${workpath}" ]; then #Erster Start
        lookback="$(choose_value 'Initial-Start\nHow many day look back?' '{"1", "5", "10", "15", "25"}')"
        lookback="((${lookback}*24*60*60))"
        keeplog="$(choose_value 'Set number of days\nwhich should keep in TMLogBar' '{"5", "10", "15", "25"}')"
        laststate="99"
        tminterval="$(choose_value 'TM-Backup-Interval in hours' '{"1", "4", "24", "168"}')"
        lasttm=2000000000
        lastrun=0
        mkdir "${workpath}"
        cd "${workpath}"
        get_tm_log "${lookback}" # Time in Seconds 4-Days="345600"
        lastrun=$((${aktdate_s}-(5*60*60)))
        init=1
    else # Jeder weiterer Start
        read_header
    fi
    if [ -e "TMLogBar.run" ]; then exit; else touch TMLogBar.run; fi
    nexttm_s=$((((${tminterval}+2)*60*60)+${lasttm}))
    running="$(tmutil status | grep "Running" | cut -d "=" -f 2)"; running="${running#* }"; running="${running%;*}"
    if [ "$running" = "0" ]; then  saverun="${aktdate_s}"; else saverun="${lastrun}"; fi
}
function shrink_logs {
    find ${workpath}/TMLog*.log -mtime +${keeplog} -exec rm {} \; 1> /dev/null
    if ls ${workpath}/TD_*.txt 1> /dev/null 2>&1; then
        find ${workpath}/TD_*.txt -mtime +${keeplog} -exec rm {} \; 1> /dev/null
    fi

}
function i_work_at_line {
    echo $line >> "${piecelog}"
    if [[ "$line" =~ '[com.apple.TimeMachine:TMLogError] Error: Error' ]]; then # Fehlerbehandlung
        code="$(echo "$line" | cut -d "=" -f3)"; code="${code% \"*}"; i_hour="${line:11:2}"; i_minutes="${line:14:2}"  
        error="TMLogError reports an Error at ${i_hour}:${i_minutes} - Code=${code} - Watch log!"
        send_message "Error: TMLogBar" "The TM-Log ${i_hour}:${i_minutes} reports Error ${code}"
    elif [[ "$line" =~ "Backing up to" ]]; then
        destination="$(echo "$line" | cut -d ":" -f6)";
        destination="${destination#*/Volumes/}";destination="${destination%/*}";                   
        if [ $failed -eq 18 ]; then failed=99; fi;
    elif [[ "$line" =~ "Backup failed with error 18" ]] || [ $failed -eq 99 ]; then failed=18; #Backupdisk not found
    elif [[ "$line" =~ "] Copied " ]] && [[ "$line" =~ "Linked" ]]; then # Zusammenstellen welche Laufwerke und welche Menge gesichert werden
        size="${line:80:${#line}}"; size="${size#*(}"; size="${size%)*}"
        aktvolume="${line#*volume}"; aktvolume="${aktvolume%. L*}"
        if [ "$volumes" != "" ]; then volumes="${volumes} /"; fi
        volumes="${volumes}${aktvolume}"
        unit="$(echo $size | cut -d " " -f2)"
        size="$(echo "$size" | cut -d " " -f1)";
        if [ "$partsize" != "" ]; then partsize="${partsize} / "; fi
        partsize="${partsize}${size}${unit}"
        size="$(echo "$size" | sed 's/','/'.'/g')"
        factor=1
        case "$unit" in
            Byte) factor=0.001;;
            GB)   factor=1000;;
            TB)   factor=1000000;;
        esac
        wholesize="$(echo "scale=1;(${wholesize}+${size}*${factor})/1" | bc)"
    elif [[ "$line" =~ "Backup completed successfully." ]]; then
        failed=0;
        i_getlogdate; endtime="${time}"
    elif [[ "$line" =~ "required (including padding)," ]]; then avail_mem="${line#*including padding), }"; avail_mem="${avail_mem% available}";
    elif [[ "$line" =~ "backups using age-based thinning" ]]; then
        del_count=${line#*Thinning }; del_count=${del_count% backups*}
    elif [[ "$line" =~ "Cancellation timed out - exiting" ]]  || [ $failed -eq 99 ]; then failed=10;
    elif [[ "$line" =~ "Backup canceled" ]] || [ $failed -eq 99 ];  then failed=10;
    elif [[ "$line" =~ "Backup failed with error 26:" ]]; then failed=26; 
    elif [[ "$line" =~ "Backup failed with error 29:" ]]; then failed=29; send_message "Error: TMLogBar" "${i_hour}:${i_minutes} Authentification error";
    elif [[ "$line" =~ "Backup failed with error 21:" ]]; then failed=21; send_message "Error: TMLogBar" "${i_hour}:${i_minutes} Error 21 unkown error";
    elif [[ "$line" =~ "Displaying verification failure dialog for" ]]; then failed=11; send_message "Error: TMLogBar" "${i_hour}:${i_minutes} Sparsebundle-Corruption";
    elif [[ "$line" =~ "[com.apple.TimeMachine:General] Completed backup: " ]]; then backupname="$(echo "$line" | cut -d ":" -f6)";
    elif [[ "$line" =~ "Failed to unmount '/Volumes/" ]]; then
        no_umount="1";
    fi
}
function i_checknewpartlog {
    if [[ "$line" =~ "Starting manual backup" ]] || [[ "$line" =~ "Starting automatic backup" ]] || [[ "$line" =~ "Backup failed with error 18" ]]; then
        backup_mode="${line#*com.apple.TimeMachine:General] Starting }"; backup_mode="${backup_mode% backup*}"
        i_getlogdate; starttime="${time}"
        mainpid="$(getpid "$line")"
        piecelog="TMLogBar_${datum}_${hour}.${minutes}_${mainpid}.log"
        if [ ! -e "$piecelog" ]; then i_work_at_line; writeline=1; else mainpid=""; continue; fi # Log nur schreiben, wenn nicht schon vorhanden
    else 
        continue
    fi
}
function i_reset_var {
    mainpid=""; partpid="XXXXXX"
    lastline=""
    error="-"
    destination="not found"
    wholesize=0
    partsize=""
    volumes=""
    failed=99
    avail_mem=""
    duration=""
    del_count=""
    no_umount="0"
    backup_mode="undef"
    writeline=0
}
function i_writeconfig {
    if [ $failed -gt 9 ]; then
        duration="-"; wholesize="-"; partsize="-"
    else
        duration="$(((${endtime}-${starttime})/60))"
        if [ "${#duration}" = "1" ]; then duration="  ${duration}"; fi
    fi
    echo "${piecelog};${duration};${failed};${error};${destination};${volumes};${partsize};${wholesize};${avail_mem};${del_count};${no_umount};${backup_mode};${backupname}" >> "${piecelog}"
    laststate=${failed}
}
function separat_log_tm {
    i_reset_var
    while read -r line; do
        if [[ "$line" =~ "backupd-helper" ]]; then continue; fi #only nessesary backupd-lines
        if [ "$mainpid" = "" ]; then
            i_checknewpartlog
        else
            partpid=$(getpid "$line")
            if [ "${partpid}" = "" ]; then echo "$line" >> "${piecelog}"; continue; fi # Ausgabe von Zeilen mit Zeilenumbruch
            if [[ "$line" =~ "Starting manual backup" ]] || [[ "$line" =~ "Starting automatic backup" ]] || [[ "$line" =~ "Backup failed with error 18" ]] ; then
                i_writeconfig
                lasttm=${endtime}
                writeline=0
                i_reset_var
                i_checknewpartlog
            else 
                i_work_at_line
            fi
        fi
    done < "${templog}"
    rm "${templog}" > /dev/null
    if [ "$running" = "1" ] && [ "${piecelog}" != "" ]; then # Wenn TM läuft wir das letzte, unvollständige Log gelöscht
        rm "${workpath}/${piecelog}" > /dev/null
    else
        if [ "$writeline" = "1" ]; then 
            i_writeconfig
            lasttm=${endtime}
        fi
    fi
    write_header
}
function makemenu {
    if [ ${aktdate_s} -gt ${nexttm_s} ] && [ ${running} != "1" ]; then sign_lasttm="⚠️"; else sign_lasttm=""; fi
    case "$laststate" in
        0) img="$img_good";;
        10) img="$img_nothing";;
        18) img="$img_caution";;
        26) img="$img_nothing";;
        *) img="$img_error";;
    esac
    if [ "${error}" != "-" ] && [ ${failed} -le 10 ]; then img="$img_caution"; fi
    echo "${sign_lasttm} | image=${img}"
    echo "---"
    echo "TimeMachine Log Bar $version | color=black"
    if [ "$tme" = "1" ]; then
        tmestatus=$(/usr/local/bin/tmectl info | head -n3)
        if [[ "$tmestatus" =~ "Deferred:" ]]; then nextrun=$(echo "$tmestatus" | grep "Deferred:" | cut -d ":" -f 2 | head -n1); 
            else nextrun=$(echo "$tmestatus" | grep "Next run" | cut -d "n" -f2 | head -n1); fi
        echo "Next Run: ${nextrun:1:20}"
    fi
    if [ "${sign_lasttm}" != "" ]; then 
        echo "---"
        echo "Lastrun greater ${tminterval}h - Resume | color=red bash='$0' param1=resume terminal=false refresh=true"
        echo "---"
    fi
    echo "---"
    olddat=""
    for file in ${workpath}/TMLog*.log; do
        conf_line="$(tail -n 1 ${file})"
        filename="$(echo "$conf_line" | cut -d ";" -f1)"
        datum="$(echo "$filename" | cut -d "_" -f2)"
        zeit="$(echo "$filename" | cut -d "_" -f3)"; zeit="${zeit/./:}"
        duration="$(echo "$conf_line" | cut -d ";" -f 2)"     # Time of the TM-Run
        failed=$(echo "$conf_line" | cut -d ";" -f 3)       # State of the TM-Run

        # Fehlerstatus: Okay-Status < 10!
        case $failed in
            0) stat_text="Backup successful"; stat_col="green";;
            10) stat_text="Backup canceled"; stat_col="silver";;
            11) stat_text="Sparsebundle corrupted"; stat_col="red";;
            18) stat_text="Backup Disk not found"; stat_col="red";;
            21) stat_text="Backup failed with error 21"; stat_col="red";;
            26) stat_text="The connection interrupted"; stat_col="#FF8000";;
            29) stat_text="Authentification Error"; stat_col="red";;
            *) stat_text="Unknown Error - Check Log"; stat_col="red";;
        esac
        error="$(echo "$conf_line" | cut -d ";" -f 4)"
        if [ "${error}" != "-" ] && [ ${failed} -le 10 ]; then stat_col="#FF8000"; fi # Orange
        destination="$(echo "$conf_line" | cut -d ";" -f 5)"  # Name of the TM-Destination
        volumes="$(echo "$conf_line" | cut -d ";" -f 6)"      # Name of the different svaed Volumes
        partsize="$(echo "$conf_line" | cut -d ";" -f 7)"     # Partsize of the different svaed Volumes
        wholesize="$(echo "$conf_line" | cut -d ";" -f 8)"    # Whole Size of the saved TM-Session
        avail_mem="$(echo "$conf_line" | cut -d ";" -f 9)"    # Availibel memory of the Backup-Disk
        del_count="$(echo "$conf_line" | cut -d ";" -f 10)"   # Nummer of expired and erased TMs
        no_umount="$(echo "$conf_line" | cut -d ";" -f 11)"   # set if last run has problems unmounting tm-path
        backup_mode="$(echo "$conf_line" | cut -d ";" -f 12)" #undef, automatic, manual
        backupname="$(echo "$conf_line" | cut -d ";" -f 13)"  # Backupname für Timedog
        if [ "$olddat" != "$datum" ]; then echo "${datum} | color=black"; fi
        case "$backup_mode" in
            automatic) bm_icon="$bmode_auto";;
            manual)    bm_icon="$bmode_man";;
            *)         bm_icon="$bmode_undef";;
        esac
        if [ ${failed} -lt 10 ]; then menu="--${zeit} - ${duration}min - ${wholesize%.*}MB"; else menu="--${zeit} - ${stat_text}"; fi
        echo "${menu} | image=${bm_icon} color=$stat_col bash='$0' param1=openlog param2='${workpath}/${filename}' terminal=false refresh=false"
        echo "----Location: ${destination} | color=black"
        if [ "${avail_mem}" != "" ]; then echo "----Avail-Storage: ${avail_mem} | color=black"; fi
        if [ "$wholesize" != "-" ]; then echo "----Backup-Size: ${wholesize%.*}MB| color=black"; fi
        if [ "${volumes}" != "" ]; then echo "----Incl. Volumes: ${volumes} | color=black"; fi
        if [ "$partsize" != "-" ]; then echo "----Part-Size: ${partsize} | color=black"; fi
        if [ "$duration" != "-" ]; then echo "----Duration: ${duration}min | color=black"; fi
        echo "----State: ${stat_text} | color=$stat_col"
        if [ "$del_count" != "" ]; then echo "----Expired Backup: ${del_count} | color=black"; fi
        if [ "$error" != "-" ]; then 
            echo "----${error} | color=red";
        else   
             if [ "$backupname" != "" ] && [ "$tme" = "1" ] && [ "$failed" = "0" ]; then  echo "----▶︎ Timedog-Compare | color=black bash='$0' param1=timedog param2='${backupname}' terminal=true refresh=false"; fi
        fi
        olddat="${datum}"
    done
    echo "---"
    echo "Preferences"
    echo "--Refresh | color=black bash='$0' param1=refresh terminal=false refresh=true"
    echo "--View Realtime Log | color=back bash='$0' param1=show_tm terminal=true refresh=false"
    echo "--Set Keep-Log-Value | color=black bash='$0' param1=setkeeplog terminal=false refresh=true"
    echo "-----"
    echo "--Reload Database | color=back bash='$0' param1=reset terminal=false refresh=true"
    if [ "$no_umount" != "0" ]; then echo "-----"; echo "--Umount $destination | color=black bash='$0' param1=unmount param2='${destination// /\\ }' terminal=false refresh=false"; fi
    rm TMLogBar.run 2>&1
}

function tmrun {
    tmstatus=$(tmutil status)

    running=$(echo "$tmstatus" | awk '/Running/ {print $3}' | cut -d ";" -f1 )
    stopping=$(echo "$tmstatus" | awk '/Stopping/ {print $3}' | cut -d ";" -f1 )
    percent="$(echo "$tmstatus" | awk '/Percent/ {print $3}' | cut -d "\"" -f2 | sed 's/;//g')" 
    backup_phase=$(echo "$tmstatus" | awk '/BackupPhase / {print $3}' | cut -d ";" -f1 )
    if [ "$backup_phase" = "Copying" ]; then 
        percent="$(echo "scale=0;${percent}*100/1" | bc | tail -n1)"
    fi
    time_remaining=$(echo "$tmstatus" | awk '/TimeRemaining / {print $3}' | cut -d ";" -f1 )
    cur_bytes=$(echo "$tmstatus" | awk '/bytes / {print $3}' | cut -d ";" -f1 )
    if [ "$cur_bytes" != "" ]; then cur_bytes="$(echo "scale=0;$cur_bytes/1000000" | bc)MB"; fi
    total_bytes=$(echo "$tmstatus" | awk '/totalBytes / {print $3}' | cut -d ";" -f1 )
    if [ "$cur_bytes" != "" ]; then total_bytes="$(echo "scale=0;$total_bytes/1000000" | bc)MB"; fi
 
    timerem=$(echo "$tmstatus" | awk '/TimeRemaining / {print $3}' | cut -d ";" -f1 )
    if [ "$timerem" != "" ]; then timerem="Restliche Zeit: $(echo "scale=0;$timerem/60" | bc)min"; fi

    if [ "$running" = "0" ]; then 
        status_line=""
    elif [ "$stopping" = "1" ]; then 
    actstate="Stopping"
        status_line="Stopping";
    else
        if [ "$percent" = "-1" ]; then 
            actstate="Preparing"
            status_line="Preparing"
        else   
            if [ "$backup_phase" = "Copying" ]; then  
                actstate="${percent}%\n${total_bytes}"
                status_line="Copying ($cur_bytes / $total_bytes)"
            elif [ "$backup_phase" = "ThinningPreBackup" ]; then 
                actstate="Thining\nPostBackup"
                status_line="ThinningPostBackup"
            else
                status_line="Completing"
                actstate="Abschluß"
            fi
        fi
    fi
    echo "$actstate|image=${tmicon} size=8 "
    echo "---"
    echo "$status_line"
    echo "$timerem"
    echo "---"
    echo "View Realtime Log | color=back bash='$0' param1=show_tm terminal=true refresh=false"
    echo "Refresh | color=black bash='$0' param1=refresh terminal=false refresh=true"
    echo "Skip Realtimeview | color=black bash='$0' param1=skiprmv terminal=false refresh=true"
}

function wait_log {
    if [ "$loglevel" != "0" ]; then
        echo "$(date): $1" >> "${workpath}/TMLogBar_Start.txt"
    fi
}
# --- externe Routinen ---
if [ "$1" = 'wait_tm' ]; then
    waittime=15
    waitcycle=2
        if [ -e "${workpath}/.tmrun" ]; then exit; fi
            wait_log "Refresh TMlogBar startet"
            touch ${workpath}/.tmrun
            tmrunning=1
            while [ ${tmrunning} -eq 1 ]; do
                tmrunning="$(tmutil status | grep "Running" | cut -d "=" -f 2)"; tmrunning="${tmrunning#* }"; tmrunning="${tmrunning%;*}"
                if [ ${tmrunning} -eq 1 ]; then 
                    wait_log "TM is running - sleeping $waittime"
                    for ((i=0; i<=$waitcycle; i++)) do 
                        open -g bitbar://refreshPlugin?name=TMLogBar*
                        sleep $waittime; 
                        if [ ! -e "${workpath}/.tmrun" ]; then tmrunning=0; fi #falls Realtimeview geskipt wurde
                    done
                fi
            done
            sleep 15
            if [ -e "${workpath}/.tmrun" ]; then rm ${workpath}/.tmrun; fi
            open -g bitbar://refreshPlugin?name=TMLogBar*
            wait_log "Bitbar opened! Anzahl Prozesses:$isrunning"
            wait_log "------------------------------------------"
        exit
fi
# --- Buttons verarbeiten ---
if [ "$1" = 'timedog' ]; then
    backupname="$2"
    osascript -e 'tell application "System Events"              
        set visible of application process "Terminal" to false
    end tell'
    depth="$(choose_value 'Timedog\nFolderdepth?' '{"4", "5", "6", "7", "8"}')"
    if [ ! -e "${workpath}/TD_${backupname}_d${depth}.txt" ]; then
        sudo timedog -d ${depth} -l -m 5M -H -s ${backupname} > "${workpath}/TD_${backupname}_d${depth}.txt"
    fi
    open "${workpath}/TD_${backupname}_d${depth}.txt" 
    kill -9 $PPID
    exit
fi 
if [ "$1" = 'skiprmv' ]; then
    if [ -e "${workpath}/.tmrun" ]; then rm ${workpath}/.tmrun; fi
fi
if [ "$1" = 'show_tm' ]; then
    filter='processImagePath contains "backupd" and subsystem beginswith "com.apple.TimeMachine"'
    start="$(date -j -v-12H +'%Y-%m-%d %H:%M:%S')"
    log show --style syslog --info --start "$start" --predicate "$filter"
    log stream --style syslog --info --predicate "$filter"
    read answer
    exit
fi
if [ "$1" = 'unmount' ]; then
    vol=$2
    initial_start
    is_activ="$(df -h | grep "$vol" | cut -d " " -f1)"
    if [ "${running}" = "0" ] && [ "${is_activ}" != "" ]; then
        result=$(osascript -e "do shell script \"diskutil umount force ${is_activ}\" with administrator privileges")
        result=$(osascript -e 'tell app "Finder" to display dialog "'"Tried to umount ${is_activ}.\nReturned: $result"'" with icon note buttons {"OK"}')
    fi
    exit
fi
if [ "$1" = 'setkeeplog' ]; then
    initial_start
    keeplog=$(choose_value 'Set number of logs\nwhich keep in TMLogBar' '{"10", "30", "50", "100"}')
    write_header
    exit
fi
if [ "$1" = 'openlog' ]; then eval open "$2"; exit; fi
if [ "$1" = 'refresh' ]; then echo; exit; fi
if [ "$1" = 'reset' ]; then rm -R ${workpath}; exit; fi
if [ "$1" = 'resume' ]; then read_header; lasttm="$(date +%s)"; write_header exit; fi
# --- MAIN ---

if [ ! -e "${workpath}/.tmrun" ]; then
    initial_start
    separat_log_tm
    shrink_logs
    makemenu
else   
    tmrun
fi
exit
