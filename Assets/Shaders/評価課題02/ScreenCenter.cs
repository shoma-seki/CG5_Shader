using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenCenter : MonoBehaviour
{
    public Material mat;

    void Update()
    {
        Vector3 worldCenter = GetComponent<Renderer>().bounds.center;

        // モデル中心が画面上のどこにあるか
        Vector3 screenPos = Camera.main.WorldToScreenPoint(worldCenter);

        // 0〜1 へ正規化
        Vector2 screenUV = new Vector2(
            screenPos.x / Screen.width,
            screenPos.y / Screen.height
        );

        mat.SetVector("_ModelScreenCenter", screenUV);
    }
}
