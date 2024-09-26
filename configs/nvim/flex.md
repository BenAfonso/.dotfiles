### Step 1 - Fetch

```
import requests
x = requests.get('https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY')
print(x.text
```

### Step 2 - Interpolate

```
{"copyright":"Mike Selby","date":"2024-08-22","explanation":"In silhouette against a crowded star field along the tail of the arachnological constellation Scorpius, this dusty cosmic cloud evokes for some the image of an ominous dark tower. In fact, monstrous clumps of dust and molecular gas collapsing to form stars may well lurk within the dark nebula, a structure that spans almost 40 light-years across this gorgeous telescopic portrait. A cometary globule, the swept-back cloud is shaped by intense ultraviolet radiation from the OB association of very hot stars in NGC 6231, off the upper right corner of the scene. That energetic ultraviolet light also powers the globule's bordering reddish glow of hydrogen gas. Hot stars embedded in the dust can be seen as bluish reflection nebulae. This dark tower and associated nebulae are about 5,000 light-years away.   Growing Gallery: Moon Eclipses Saturn in August 2024","hdurl":"https://apod.nasa.gov/apod/image/2408/DarkTowerCDK700-Selby.jpg","media_type":"image","service_version":"v1","title":"The Dark Tower in Scorpius","url":"https://apod.nasa.gov/apod/image/2408/DarkTowerCDK700-Selby1024.jpg"}
```

### Step 3 - jq

`jq '{ copyright, date, url }'`

```
{"copyright":"Mike Selby","date":"2024-08-22","explanation":"In silhouette against a crowded star field along the tail of the arachnological constellation Scorpius, this dusty cosmic cloud evokes for some the image of an ominous dark tower. In fact, monstrous clumps of dust and molecular gas collapsing to form stars may well lurk within the dark nebula, a structure that spans almost 40 light-years across this gorgeous telescopic portrait. A cometary globule, the swept-back cloud is shaped by intense ultraviolet radiation from the OB association of very hot stars in NGC 6231, off the upper right corner of the scene. That energetic ultraviolet light also powers the globule's bordering reddish glow of hydrogen gas. Hot stars embedded in the dust can be seen as bluish reflection nebulae. This dark tower and associated nebulae are about 5,000 light-years away.   Growing Gallery: Moon Eclipses Saturn in August 2024","hdurl":"https://apod.nasa.gov/apod/image/2408/DarkTowerCDK700-Selby.jpg","media_type":"image","service_version":"v1","title":"The Dark Tower in Scorpius","url":"https://apod.nasa.gov/apod/image/2408/DarkTowerCDK700-Selby1024.jpg"}
```