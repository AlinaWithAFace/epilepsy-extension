## Web Based Screening Tool for Photosensitive Epilepsy Triggers


## Authors


### Connor Onweller, Computer Information Science, University of Delaware, onweller@udel.edu


### Alina Christenbury, Computer Information Science, University of Delaware, alinac@udel.edu



1. Introduction

Photosensitive epilepsy (PSE) is a condition that affects approximately 5% of people with epilepsy and about 0.025% of the general population [1]. Certain visual stimuli such as flashing lights and contrasting patterns may trigger epileptic seizures in people who experience this photosensitive epilepsy. The primary source of these triggers has long been, and continues to be, televisions due to their slow screen refresh rate. To mitigate this risk various guidelines were put forth and steps were taken in some countries to regulate the content allowed on broadcast television. It also has become common practice for film, television, and video games to provide warnings for scenes that might trigger seizures in people that experience PSE.  As a result of these regulations and guidelines production companies and television broadcast companies began using automated testing software to assess a video’s compliance with the rules. Such interventions help to protect people with PSE from life threatening seizures.

While the LCD screens of modern computers don’t present the same risk as the flickering television screen, digital media with flashing can still trigger epileptic seizure in viewers with PSE. Due to the ways in which we tend to consume digital media, this presents a problem: in a fragmented media landscape, ensuring that the videos we watch have been screened for people with PSE is much more challenging.  On many social media and video platforms problematic content is unavoidable and on sites/apps like Instagram and YouTube which enable auto-play by default, they may begin playing without warning. While there have been recent calls for social media to introduce warning messages on posts that may trigger seizures in people with PSE, little has been done so far and change is unlikely to happen without regulations [6]. Screening of posts on these platforms poses a significant challenge, considering the sheer volume of content they house; as of 2019, over 500 hours of video content are uploaded _every minute_. [11]

In the meantime, we would like to explore ways in which people with PSE can screen videos for potential triggers before watching. Current testing systems are either inadequate when it comes to following modern guidelines or are too expensive for users of sites like YouTube or other social media platforms to regularly screen videos for dangerous stimuli. Ideally there would be a platform that would allow users to screen videos for compliance with PSE trigger guidelines, without requiring the users to invest a large amount of time or effort into the process of screen the media they want to consume.



2. Related Work

The gold standard for testing appears to be the Harding Flash and Pattern Analyser. It is an automatic test that screens videos, websites, video games, and other digital media for compliance with international guidelines on flashing and spatial patterns in media [2][3]. It has been used for years and is considered reliable; however, we view the analyzer as a somewhat flawed solution to the problem we posed. The cost of using this product might be a significant deterrent for people trying to screen the web content they consume. While Cambridge Research Systems (the creator of the Harding Flash Pattern Analyser) has begun offering an online tool to test audio-visual material, available at [https://www.onlineflashtest.com](https://www.onlineflashtest.com), the cost of screening a thirty-minute video is £100.00 [5]. For the average user with PSE that wants to know whether a video could be problematic for them, such a test is likely to be prohibitively expensive.

Another popular tool for screening PSE is the Photosensitive Epilepsy Analysis Tool (PEAT) [3][4]. PEAT is a downloadable MS Windows application that allows users to analyze embedded content in websites to determine if that content is likely to trigger a seizure in someone with PSE. The tool is free to use with the restriction that “Use of PEAT to assess material commercially produced for television broadcast, film, home entertainment, or gaming industries is prohibited” [4]. The developers of PEAT recommend that those wishing to screen the above forms of media should use the Hard Flash and Pattern Analyser. As a result PEAT does not appear to be as rigorous of a platform for testing video as the Harding test, and it is instead more of a tool for developers and web designers. Furthermore, because it is a desktop application, specifically a Windows application, users would need to use a Windows computer and have to download the videos they want to screen, load it into the application, and wait then for feedback, which is a fairly arduous process for users just looking to browse the web safely.



3. Proposed Solution

Our solution is to develop a browser extension that allows users to run it on a YouTube video or a link to a video to test it for compliance for guidelines and regulations regarding flashing images patterns in videos. This would involve creating a simple plugin-based user interface where users would be able to activate the extension when they visit a YouTube page to screen the video on that page and review feedback from the screening test before watching the video. Our goal is to provide an easier mechanism for users to receive feedback on the videos they want to watch, as well as provide more meaningful feedback than existing solutions. Implementing the screening algorithm would involve reviewing guidelines on flashing lights and patterns as well as getting a sense for how programs like the Harding Test and PEAT approach this problem. An approach might be building a machine learning model and database of flashing videos to test against other videos that are less likely to be triggers.

We will use standards like section two of the Ofcom broadcasting guidelines and the World Wide Web Consortium’s  Web Content Accessibility Guidelines as a guide for what video content our classifier should screen for [6][7]. Research in the area of photosensitive epilepsy have quantified what intensity and frequency of flashing patterns are considered hazardous, making the task of classifying harmful videos a manageable one [10].

We will likely utilize OpenCV to implement the backend screening process,  Javascript to to write the browser extension, and git/GitHub for project management and collaboration. We will also consult the PEAT project (which is partially open source) to get a better understanding of approaches taken by existing solutions [9].

We do not foresee a need for any significantly expensive resources. While the final project would require hosting a website and server, this won’t be necessary during the prototyping stage.



4.  Evaluation Plan

We will build a dataset of videos that trigger epilepsy and videos that don’t and see if our tool can correctly flag videos that are triggers, evaluating our system based on it’s classification accuracy/precision. We hope to involve users with photosensitive epilepsy in the design process. We plan to recruit people with PSE from the subreddit  r/epilepsy, and will conduct semi-structured interviews at the beginning of our design process, to get a sense of the challenges these users face when using the internet. We also plan on conducting interviews with potential users with PSE to evaluate and receive feedback on our system’s user interface as we develop it, as well as receive feedback on the type of information the classifier provides. 



5. Collaboration Plan

We plan to use git for source control, GitHub for bug tracking, hold weekly meetings on Mondays at 11am, and work independently on our own time with check-ins during meetings.



6. Timeline

| Sprint 1: Mar-8 to Mar-19 | Data collection, finish literature review, determine potential users and collect feedback from the Epilepsy subreddit |
|:-:|:-:|
| Sprint 2: Mar-22 to Apr-2 | Start work on the classifier, data collection continued |
| Paper Check-in: Mar-29 |  |
| Sprint 3: Apr-5 to Apr-16 | Classifier work continued, end with evaluation with end users of classifier feedback |
| In-class Artifact Review: Apr-7 |  |
| In-Class Presentations: Apr-12 Classifier Demo |  |
| Sprint 4: Apr-19 to Apr-30 | Make adjustments to classifier, start work on the chrome extension |
| Sprint 5: May-3 to May-14 | Chrome extension continued, user testing |
| In-class Artifact Review II: May 7 Chrome extension Demo |  |
| Sprint 6: May-17 to May-26 | Finalized User testing, final touches |
| Final Project Presentations: May 26 |  |



## 


## References



1. Martins da Silva, A. et al. (2017) Photosensitivity and epilepsy: Current concepts and perspectives—A narrative review, Seizure - European Journal of Epilepsy, Volume 50, 209 - 218 [https://www.seizure-journal.com/article/S1059-1311(17)30252-2/fulltext#secsect0020](https://www.seizure-journal.com/article/S1059-1311(17)30252-2/fulltext#secsect0020)
2. Cambridge Research Systems Ltd., 2021. Retrieved February 2021 from [www.hardingfpa.com/](http://www.hardingfpa.com/)
3. Web technology for developers. Retrieved February 25, 2021, from [https://developer.mozilla.org/en-US/docs/Web/Accessibility/Seizure_disorders](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Seizure_disorders)
4. Photosensitive epilepsy analysis tool (peat). (2021, February 04). Retrieved February 25, 2021, from [https://trace.umd.edu/peat/](https://trace.umd.edu/peat/)
5. Clearcast online flash test. Retrieved February 25, 2021, from [https://www.onlineflashtest.com/](https://www.onlineflashtest.com/)
6. Epilepsy charity calls for social media seizure warnings. (2019, April 16). Retrieved February 25, 2021, from [https://www.bbc.com/news/uk-47943607](https://www.bbc.com/news/uk-47943607)
7. “Section Two: Harm and Offence.” _Ofcom_, Ofcom, 3 Mar. 2021, [www.ofcom.org.uk/tv-radio-and-on-demand/broadcast-codes/broadcast-code/section-two-harm-offence](www.ofcom.org.uk/tv-radio-and-on-demand/broadcast-codes/broadcast-code/section-two-harm-offence).
8. _Web Content Accessibility Guidelines (WCAG) 2.0_, World Wide Web Consortium, [www.w3.org/TR/WCAG20/](www.w3.org/TR/WCAG20/).
9. rakeeb123. “rakeeb123/PEAT_V2.” _GitHub_, [github.com/rakeeb123/PEAT_V2](https://github.com/rakeeb123/PEAT_V2).
10. Harding, Graham et al. “Photic- and pattern-induced seizures: expert consensus of the Epilepsy Foundation of America Working Group.”_ Epilepsia vol._ 46,9 (2005): 1423-5. doi:10.1111/j.1528-1167.2005.31305.x 
11. [https://www.statista.com/statistics/259477/hours-of-video-uploaded-to-youtube-every-minute/](https://www.statista.com/statistics/259477/hours-of-video-uploaded-to-youtube-every-minute/)

Guidelines (from https://trace.umd.edu/information-about-photosensitive-seizure-disorders/):



*   [Section 508 of the Workforce Investment Act of 1998](https://www.section508.gov/manage/laws-and-policies); sections 1194.21 (k) and 1194.22 (j) (computer software and web content)
*   [Web Content Accessibility Guidelines (WCAG) 1.0](http://www.w3.org/TR/1999/WAI-WEBCONTENT-19990505/)
*   [Web Content Accessibility Guidelines (WCAG) 2.0](http://w3.org/TR/WCAG20/) (The PEAT analysis matches the specifications used in WCAG 2.0)
*   [HFES 200](http://www.hfes.org/Publications/ProductDetail.aspx?Id=76) Software User Interfaces Standard
*   [ISO 9241-171](http://www.iso.org/iso/iso_catalogue/catalogue_tc/catalogue_detail.htm?csnumber=39080) Software Accessibility Standard

Also



*   [https://www.ofcom.org.uk/__data/assets/pdf_file/0023/104657/Section-2-Guidance-Notes.pdf](https://www.ofcom.org.uk/__data/assets/pdf_file/0023/104657/Section-2-Guidance-Notes.pdf)
*   [https://www.epilepsy.com/sites/core/files/atoms/files/Epilepsia%20vol%2046%20issue%209%20Photosensitivity.pdf](https://www.epilepsy.com/sites/core/files/atoms/files/Epilepsia%20vol%2046%20issue%209%20Photosensitivity.pdf)
*   https://www.epilepsy.com/learn/triggers-seizures

Related projects



1. [https://github.com/rakeeb123/PEAT_V2](https://github.com/rakeeb123/PEAT_V2)
2. [https://www.epilepsyecosystem.org/](https://www.epilepsyecosystem.org/)
3. [http://hardingtest.com/](http://hardingtest.com/)

Research:



*   [https://www.seizure-journal.com/article/S1059-1311(17)30252-2/fulltext#secsect0065](https://www.seizure-journal.com/article/S1059-1311(17)30252-2/fulltext#secsect0065)
*   [https://onlinelibrary-wiley-com.udel.idm.oclc.org/doi/epdf/10.1111/j.1528-1157.1994.tb01791.x](https://onlinelibrary-wiley-com.udel.idm.oclc.org/doi/epdf/10.1111/j.1528-1157.1994.tb01791.x)
*   [https://onlinelibrary.wiley.com/doi/full/10.1111/j.1528-1167.2011.03319.x](https://onlinelibrary.wiley.com/doi/full/10.1111/j.1528-1167.2011.03319.x)