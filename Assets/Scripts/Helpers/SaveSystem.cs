using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;

public static class SaveSystem
{

	public static void SaveData(SaveState data)
	{
		BinaryFormatter formatter = new BinaryFormatter();
		string path = Application.persistentDataPath + "/taceo.userdata";
		FileStream stream = new FileStream(path, FileMode.Create);

		formatter.Serialize(stream, data);
		stream.Close();
	}

	public static SaveState LoadData()
	{
		string path = Application.persistentDataPath + "/taceo.userdata";

		if (File.Exists(path))
		{
			BinaryFormatter formatter = new BinaryFormatter();
			FileStream stream = new FileStream(path, FileMode.Open);

			SaveState data = (SaveState) formatter.Deserialize(stream);
			stream.Close();

			return data;
		}
		else
		{
			Debug.LogError("Save file not found at " + path);
			return new SaveState();
		}
	}

	public static void ResetData()
	{
		SaveState ds = new SaveState();
		SaveData(ds);
	}

}
