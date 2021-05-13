# works on all gifs in the directory this file is in

#MUST BE RUN IN anaconda3 powershell enviroment
#$ conda activate pytorch
#navigate to correct dir

foreach($gifFile in ls *.gif) {
    $dirName=[io.path]::GetFileNameWithoutExtension($gifFile)
    mkdir $dirName
    ffmpeg -i $gifFile "$dirName/%04d.jpg"
}