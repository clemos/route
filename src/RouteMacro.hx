import haxe.macro.Context;
import haxe.macro.Expr;

class RouteMacro {
    public static function build(){

        var localType = Context.toComplexType(Context.getLocalType());
        var fields = [];
        var pos = Context.currentPos();

        var targetEnum = switch( localType ){
            case TPath({ params:[TPType(TPath(e))]}) : e;
            default: throw 'invalid';
        }

        var targetTypePath = {name:'Route__'+targetEnum.name+'', pack: targetEnum.pack};

        var targetAbstract = TPath(targetTypePath);

        var abstractDef = {
            fields: fields,
            kind:TDAbstract(TPath({name:"String", pack:[]}),[],[TPath({name:"String",pack:[]})]),
            name: targetTypePath.name,
            pack: targetTypePath.pack,
            pos: pos
        };
        
        fields.push( {
          name: 'new',
          doc: null,
          meta: [],
          access: [APublic],
          kind: FFun({
            args: [ { name : "s", type : TPath({name:"String", pack:[]}) } ],
            expr: macro this = s,
            ret: TPath({name:"Void", pack:[]})
          }),
          pos: pos
        } );

        switch( localType ) {
            case TPath(p):
                var constr = targetTypePath;
                fields.push( {
                    name: 'fromString',
                    doc: null,
                    meta: [{name:":from", pos: pos}],
                    access: [APublic,AStatic],
                    kind: FFun({
                        args: [ { name : "s" , type : TPath({name:"String", pack:[]}) } ],
                        expr: macro return new $constr( s ),
                        ret: null
                    }),
                    pos: pos
                });
            default: throw 'invalid';
        }


        fields.push( {
            name: 'to${targetEnum.name}',
            doc: null,
            meta: [{name:":to", pos: pos}],
            access: [APublic],
            kind: FFun({
                args: [],
                expr: macro return switch( this.split('/') ) {
                    case ["article", id]: Article(id);
                    case ["item", id] if(Std.parseInt(id)!=null): Item(Std.parseInt(id));
                    default: throw 'invalid route '+this;
                },
                ret: TPath(targetEnum)
            }),
            pos: pos
        });

        fields.push( {
            name: 'from${targetEnum.name}',
            doc: null,
            meta: [{name:":from", pos: pos}],
            access: [APublic,AStatic],
            kind: FFun({
                args: [{name:"e", type: TPath(targetEnum)}],
                expr: macro return switch( e ) {
                    case Article(id): ['article',id].join('/');
                    case Item(id): ['item', Std.string(id)].join('/');
                    default: throw 'invalid route '+e;
                },
                ret: targetAbstract
            }),
            pos: pos
        });

        try {
            Context.defineType(abstractDef);
        } catch(e:Dynamic){
            trace('already declared');
        }

        return targetAbstract;
    }
}