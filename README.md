<p align="center"><img src="https://github.com/Grisgram/gml-raptor/blob/dev/_assets_/logos_and_banners/gml-raptor-anim-trans.gif" style="display:block; margin:auto; width:438px"></p>
<h1 align="center">Release 2504</h1>

`gml-raptor` is a ready-to-use project template for [GameMaker Studio 2.3+](https://gamemaker.io) with a comprehensive [wiki documentation](https://github.com/Grisgram/gml-raptor/wiki) that provides lots of classes and functions that will speed up your game development!<br/>
[The Releases page](https://github.com/Grisgram/gml-raptor/releases) contains the latest version in `.yyz` format (project template) and ready-to-import local packages in `.yymps` format.

### PLAY IT LIVE AT ITCH.IO
Just want to see the demo without cloning?<br/>
Test the html-version of the raptor-demo directly on my [itch.io](https://grisgram.itch.io/gml-raptor) page!<br/>
If you like what you see, please don't forget to ⭐ the repository and consider following me here and on itch! The more reach `raptor` gets, the faster it can evolve even more!

----

<p align="center">
In case you are a night owl like me and you want to support my work,<br/>especially the <a href="https://github.com/Grisgram/gml-raptor">gml-raptor platform for GameMaker</a>,<br/>spend me a coffee through PayPal. <p align="center"><a href="https://www.paypal.com/donate/?hosted_button_id=PL8VA5UFCPMK6" target="_blank"><img src="https://github.com/Grisgram/Grisgram/blob/main/images/paypal_donate.gif" /></a></p><p align="center">Thank you!</p>
</p>

### MAIN FEATURES

|![gms](https://user-images.githubusercontent.com/19487451/174742864-ca80b221-8799-42f0-851d-474ebbbf06be.png) Coding & Data|![gms](https://user-images.githubusercontent.com/19487451/174742864-ca80b221-8799-42f0-851d-474ebbbf06be.png) Visuals & Objects|
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
|![savegame](https://user-images.githubusercontent.com/19487451/180134446-1223e79f-0963-4438-954c-331d8827283e.png) [**Savegames**](https://github.com/Grisgram/gml-raptor/wiki/Savegame-System)<br/>Have your data saved and restored with optional encryption|![state](https://user-images.githubusercontent.com/19487451/180134498-d648abcb-ac41-4050-ac04-79046a634a66.png) [**State Machines**](https://github.com/Grisgram/gml-raptor/wiki/StateMachine)<br/>Easy to use but powerful game object control|
|![race](https://user-images.githubusercontent.com/19487451/180134457-003f837a-2e33-44af-a5fa-1f92f6aa8b22.png) [**RACE**](https://github.com/Grisgram/gml-raptor/wiki/RACE-%28The-Random-Content-Engine%29) (**RA**ndom **C**ontent **E**ngine)<br/>Loot, Random maps, Dice, all that can be random with json-based config|![animation](https://user-images.githubusercontent.com/19487451/180134463-51a17e65-f2de-415e-aadd-8ee6aa8ed7d8.png) [**Animations**](https://github.com/Grisgram/gml-raptor/wiki/Animation)<br/>Runtime sprite animations with triggers and runtime tweaks|
|![tools](https://user-images.githubusercontent.com/19487451/180134472-8e9a940f-41f0-48f4-964d-8e46dc9222b3.png) [**Tools**](https://github.com/Grisgram/gml-raptor/wiki/Tools%2C-other-Objects-and-Helpers)<br/>Utils and Helpers, like [Object Pools](https://github.com/Grisgram/gml-raptor/wiki/ObjectPool),<br/> [Logging](https://github.com/Grisgram/gml-raptor/wiki/Logger), [Crash dumps](https://github.com/Grisgram/gml-raptor/wiki/Crash-logs), [Message Broadcasting](https://github.com/Grisgram/gml-raptor/wiki/Broadcasting)|![ui](https://user-images.githubusercontent.com/19487451/180134486-7b55554d-aef1-4379-9e55-02290021b8fe.png) [**UI and Localization**](https://github.com/Grisgram/gml-raptor/wiki/UI-Subsystem)<br/>Basic [UI Controls](https://github.com/Grisgram/gml-raptor/wiki/UI-Subsystem) objects incl. [Text Input](https://github.com/Grisgram/gml-raptor/wiki/InputBox), [json-localization](https://github.com/Grisgram/gml-raptor/wiki/LG-Localization), 100% [Scribble](https://github.com/JujuAdams/scribble)-based|

### VERSION LIST
You need [![gmlogo](https://user-images.githubusercontent.com/19487451/177008359-37a3cdb7-2068-4ac8-84ef-4c455c2194de.png)](https://gamemaker.io)&nbsp;&nbsp;Studio 2.3+ to use `raptor`.<br/>
These versions of external libraries are packaged into the current `raptor` release:

| GMS Version | Scribble | SNAP | Canvas | OutlineShader | AnimatedFlag | HighScorer |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|2411|9.3.5|7.0.1|2.2|3.3|1.5|1.6|

### HOW RELEASES ARE ORGANIZED
* Find the latest release at the [Releases](https://github.com/Grisgram/gml-raptor/releases) page
* Downloadable items of a release are:
  * The raptor _project template_ (see the [wiki](https://github.com/Grisgram/gml-raptor/wiki) for instructions how use templates in GameMaker)
  * A local package containing the entire raptor with all libraries as `.yymps` file, if you don't like project templates
  * Since `Release 3.0`, a `room-template` package
  * Since `Release 3.0`, a `html-room-template` package

> [!NOTE]
> The room template packages help you speed up your development and have been added to make room creation with all the default layers and objects of raptor easier, by simply importing a package with one single room + room controller and just renaming them!


### CONTRIBUTING
I am happy, if you want to support `raptor` to become even better, just launch a pull request, explain me your changes, and I make sure, you get credited as contributor.
If you have questions, feedback or just want to discuss specific parts of this platform, just open a new thread in the [discussions](https://github.com/Grisgram/gml-raptor/discussions) for this repository. I'll do my best to answer any questions as quick as possible!
Feel free to fork, advance, fix and do what you want with the code in this repository, but please respect the MIT License and credit.<br/>


### OTHER LIBRARIES
My main goal is to provide a ready-to-use project template. I am not a big friend of "oh, yes, this is the classes, but you need to download this from here and that other thing from there and make sure, you apply this and this and this setting and best do a npm xy to have this running..." what a mess!
I do not like that. You will always find a single-download-and-run release in the template.

That being said, it leads to this requirement/fact:<br/>
`raptor` contains some other libraries that are referenced from my classes, so they are packaged together with this project template.

Some of these 'other libraries' are my own and are by default also included in the package, because I find it more easy to remove one not required folder by a simple hit of the 'Delete' key instead of browsing the file system for all bread crumbs that need to be added. It just saves time.

By default, these libraries of mine are included:

* [Outline Shader Drawer](https://github.com/Grisgram/gml-outline-shader-drawer)
* [Animated Flag](https://github.com/Grisgram/gml-animated-flag)
* [HighScorer](https://github.com/Grisgram/gml-highscorer)

### CREDITS
### Translation help and proof reading

Very special thanks to `Alex` [@pamims](https://github.com/pamims) for proof reading my version of the english language and correcting it to the _real_ version of the english language! Thank you very much for volunteering here!


### Credits for external libraries go to 

* [@JujuAdams](https://github.com/JujuAdams) and the great community at [GameMakerKitchen Discord](https://discord.gg/8krYCqr) for the [SNAP](https://github.com/JujuAdams/SNAP) Library and [Scribble](https://github.com/JujuAdams/scribble), which I packaged into this repository and the project template.

* [@tabularElf](https://github.com/tabularelf) for his [Canvas](https://github.com/tabularelf/Canvas) library and all the great support he gave me, while raptor was being made.

* [@YellowAfterLife](https://github.com/YellowAfterlife) for the [Open Link in new Tab](https://yal.cc/gamemaker-opening-links-in-new-tab-on-html5/) Browser Game extension for GameMaker, which I modified a bit to fit into the platform. This extension is also packaged into the platform and ready-to-use.

### CONTACT ME
Beside the communication channel here, you can reach me as @Grisgram on the [GameMakerKitchen Discord](https://discord.gg/8krYCqr).

(c)2022-2025 [coldrock.games](https://www.coldrock.games)

