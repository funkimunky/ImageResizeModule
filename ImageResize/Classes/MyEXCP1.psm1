class MyEXCP1: System.Exception{
    $Emessage
    MyEXCP1([string]$msg):base($msg){
        $this.Emessage=$msg
    }
    MyEXCP1(){
        
    }
}