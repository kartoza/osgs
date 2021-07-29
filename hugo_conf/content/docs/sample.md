---
title: Sample
subtitle: A sample document capabilities
custom:
  parameterOne: "Parameter One Value"
  parameterTwo: "Parameter Two Value"
categories:
- Featured
summary: "Samples of advanced shortcode content and rich media"
---

This sample document outlines some of the more advanced content creation capabilities and syntax.

Curabitur blandit tempus ardua ridiculus sed magna. Sed haec quis possit intrepidus aestimare tellus. Quisque ut dolor gravida, placerat libero vel, euismod. Plura mihi bona sunt, inclinet, amari petere vellent.
Fabio vel iudice vincam, sunt in culpa qui officia. Inmensae subtilitatis, obscuris et malesuada fames. Ambitioni dedisse scripsisse iudicaretur. Nec dubitamus multa iter quae et nos invenerat. Petierunt uti sibi concilium totius Galliae in diem certam indicere.
Morbi fringilla convallis sapien, id pulvinar odio volutpat. Hi omnes lingua, institutis, legibus inter se differunt. Non equidem invideo, miror magis posuere velit aliquet. Quid securi etiam tamquam eu fugiat nulla pariatur. Inmensae subtilitatis, obscuris et malesuada fames. Fictum, deserunt mollit anim laborum astutumque!
Curabitur blandit tempus ardua ridiculus sed magna. Sed haec quis possit intrepidus aestimare tellus. Quisque ut dolor gravida, placerat libero vel, euismod. Plura mihi bona sunt, inclinet, amari petere vellent.

---

<!-- Comments will not be visible in the rendered page -->
<!-- ![image alt text](/unsplash/photo-1579159279464-d12b399393a6.jpg) -->

{{< html >}}
  <div class="container">
    <section id="hero" class="hero is-medium is-info is-bold landing-hero">
      <div class="hero-body">
      <!-- <script>alert('hello world')</script> -->
      <h1 class="title pb-3">This is custom HTML content</h1>
      </div>
    </section>
  </div>
  </br>
{{< / html >}}

{{< center >}}
{{< figure src="/unsplash/photo-1579159279464-d12b399393a6.jpg" class="image is-128x128" >}}
{{< / center >}}

{{< center >}}
Image Caption
{{< / center >}}

---

Phasellus laoreet lorem vel dolor tempus vehicula. Idque Caesaris facere voluntate liceret: sese habere. Ab illo tempore, ab est sed immemorabili. Mercedem aut nummos unde unde extricat, amaras. Praeterea iter est quasdam res quas ex communi.
A communi observantia non est recedendum. Vivamus sagittis lacus vel augue laoreet rutrum faucibus. Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae.
Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Me non paenitet nullum festiviorem excogitasse ad hoc. Ambitioni dedisse scripsisse iudicaretur. Unam incolunt Belgae, aliam Aquitani, tertiam. Morbi fringilla convallis sapien, id pulvinar odio volutpat. A communi observantia non est recedendum.
Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Donec sed odio operae, eu vulputate felis rhoncus. Salutantibus vitae elit libero, a pharetra augue. Nihil hic munitissimus habendi senatus locus, nihil horum? A communi observantia non est recedendum.

---

{{< sample name="Sample Object" description="This is a " >}}

---

{{< highlight python "linenos=table" >}}
#!/usr/bin/env python

# Hello World!
print "Hello World"

# Simple conditional
x = 1
if x == 1:
    print("x is 1.")
{{< / highlight >}}

![image alt text](/unsplash/test.jpg)

---

<div class="title">Some Content</div>

| Index | Title             |
|-------|-------------------|
|1      |Some Content       |
|2      |Some Other Content |
|3      |Some More Content  |


---

Page Subtitle: {{< param "subtitle" >}}

Parameter One: {{< param "custom.parameterOne" >}}

Parameter Two: {{< param "custom.parameterTwo" >}}

---

{{< highlight text >}}
[Neat]({{< ref "docs/example.md" >}})
[Who]({{< relref "about.md#who" >}})

<a href="https://example.com/blog/neat">Neat</a>
<a href="/about/#who">Who</a>
{{< / highlight >}}

---

Quisque ut dolor gravida, placerat libero vel, euismod. Ambitioni dedisse scripsisse iudicaretur. Donec sed odio operae, eu vulputate felis rhoncus. Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae.
Fabio vel iudice vincam, sunt in culpa qui officia. Inmensae subtilitatis, obscuris et malesuada fames. Ambitioni dedisse scripsisse iudicaretur. Nec dubitamus multa iter quae et nos invenerat. Petierunt uti sibi concilium totius Galliae in diem certam indicere.
Cum sociis natoque penatibus et magnis dis parturient. Curabitur blandit tempus ardua ridiculus sed magna. Salutantibus vitae elit libero, a pharetra augue.
Quisque ut dolor gravida, placerat libero vel, euismod. Ambitioni dedisse scripsisse iudicaretur. Donec sed odio operae, eu vulputate felis rhoncus. Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae.
