class Main {
    static function main(){
        // var t : Route<Command> = "article/0";
        // trace(t);
        // switch( t:Command ) {
        //     case Article(id): trace('routing to article #$id');
        //     default: trace('HELLO');
        // }

        var t : Route<Command> = Command.Item(1);
        
        switch(t:Command) {
            case Item(i): trace('woohoo');
            default: trace('nooo');
        }
    }
}