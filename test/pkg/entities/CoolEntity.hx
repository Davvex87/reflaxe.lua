package pkg.entities;

class CoolEntity extends AbstractEntity
{
	public var level:Int = 1;

	public function new(level:Int = 1)
	{
		super();
		this.level = level;
	}

	public function special():Void
	{
		trace('CoolEntity uses a cool special ability! Level: $level');
	}
}
