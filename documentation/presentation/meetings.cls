\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{meetings}[2020/09/23 Simon Koenig BTMeetingTemplate]

\LoadClass[oneside, 14pt]{extarticle}

\RequirePackage[utf8]{inputenc}
\RequirePackage[paperwidth=28.1cm, paperheight=18cm, left=3.2cm,right=3.2cm,top=0.7cm,bottom=1cm,includefoot,heightrounded]{geometry}

\RequirePackage[hyperref,dvipsnames]{xcolor}
\RequirePackage{hyperref}
\RequirePackage{lastpage}
\RequirePackage{csquotes}
\RequirePackage{fancyhdr}
\RequirePackage{datetime}
\RequirePackage{mathtools}
\RequirePackage{amsmath}
\RequirePackage{titling}
\RequirePackage[noindentafter]{titlesec}
\RequirePackage{enumitem}
\RequirePackage{multicol}
\RequirePackage{wasysym}
\RequirePackage{tikz}
\usetikzlibrary{automata,positioning,calc}

%Schriftfamilien
\RequirePackage{lmodern}
\RequirePackage{helvet}%sf
\RequirePackage{ascii}%tt
\RequirePackage{newtxmath}
\RequirePackage[T1]{fontenc}
\renewcommand{\normalfont}{\sffamily}
\renewcommand{\rmfamily}{\sffamily}


\titleformat{\section}[display]
{\centering\normalfont\clearpage}
{}
{0pt}
{\huge}
\titlespacing{\section}{0pt}{0pt}{1.3em}

\titleformat{\subsection}[display]
{\normalfont}
{}
{0pt}
{\Large}
\titlespacing{\subsection}{0pt}{0pt}{0.6em}


%Standards einstellen
\mathcode`\*="8000 %Sterne durch Malpunkte ersetzen
{\catcode`\*\active\gdef*{\cdot}}


%Header und Footer-Design
\pagestyle{fancy}
\author{}%Fallback Autor leer
\date{\today}%Fallback Datum heute
\rhead{}
\lhead{}
\lfoot{\sffamily\small\theauthor}
\rfoot{\sffamily\small\thedate}
\cfoot{}
\renewcommand{\headrulewidth}{0pt}





