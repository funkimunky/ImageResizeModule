class MyErrorRecord: System.Exception{
    $Emessage
    MyErrorRecord($msg){
        $this.Emessage=$msg
    }
}