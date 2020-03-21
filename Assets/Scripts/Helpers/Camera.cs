using UnityEngine;

namespace Util
{
	public static class Camera
	{
		public static Vector3 ScreenToWorldPointPerspective(UnityEngine.Camera camera, Vector3 screenPosition, float z) {
			Ray ray = camera.ScreenPointToRay(screenPosition);
			Plane xy = new Plane(Vector3.forward, new Vector3(0, 0, z));
			xy.Raycast(ray, out float distance);
			return ray.GetPoint(distance);
		}
	}
}
