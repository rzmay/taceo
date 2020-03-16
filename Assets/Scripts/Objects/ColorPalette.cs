using System.Collections;
using System.Collections.Generic;
using System.Linq;
using JetBrains.Annotations;
using UnityEngine;

[CreateAssetMenu(fileName =  "New Color Palette", menuName = "ColorPalette")]
public class ColorPalette : ScriptableObject
{
	public string name;

	public enum Roles
	{
		primary,
		secondary,
		accent,
		background,
		neutral
	}

	[System.Serializable]
	public class ColorEntry
	{
		public string name;
		public Roles role;
		public Color color;
	}

	[SerializeField] public List<ColorEntry> colors;

	[CanBeNull]
	public ColorEntry GetColor(string name)
	{
		ColorEntry[] colorEntry = colors.Where(c => c.name == name).ToArray();
		if (colorEntry.Length > 0) return colorEntry[0];

		return null;
	}

	[CanBeNull]
	public ColorEntry GetColor(Roles role)
	{
		ColorEntry[] colorEntry = colors.Where(c => c.role == role).ToArray();
		if (colorEntry.Length > 0) return colorEntry[0];

		return null;
	}
}
