package pkg.entities;

abstract class AbstractEntity
{
	public var health(default, set):Float = 100;
	public var defense:Float = 20;
	public var damage:Float = 15;

	public var dead:Bool = false;

	public function new() {}

	public function attack(entity:AbstractEntity):Void
	{
		if (entity.dead)
			return;
		entity.health -= this.damage;
	}

	abstract public function special():Void;

	function set_health(value:Float):Float
	{
		if (value <= 0)
		{
			dead = true;
			return health = 0;
		}
		return health = value;
	}
}
