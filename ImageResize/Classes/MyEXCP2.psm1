class MyEXCP2: System.Exception{
    $Emessage
    MyEXCP2([string]$msg){
        $this.Emessage=$msg
    }
}